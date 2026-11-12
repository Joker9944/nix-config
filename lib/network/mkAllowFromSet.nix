/**
  Render `networking.firewall.extraCommands` that accept the given ports only from
  sources held in an ipset, for both address families.

  Unlike `mkAllowFrom` this emits `ip6tables` as well, because a client's v4 and
  v6 addresses are unrelated and a v4-only allowlist would admit nobody over v6.

  An empty `hash:net` set is created only when missing, before the rules
  reference it: a `-m set` rule against a missing set aborts the firewall start
  script, and the populating unit cannot be ordered before it. Existing sets are
  never compared against, so their parameters belong to whatever populates them
  and a mismatch cannot abort the script and leave the host unfiltered.

  One `-m multiport` rule is emitted per protocol and family; the `nixos-fw`
  invariants and the 15-port cap live in `mkAcceptRules.nix`.

  # Type

  ```
  mkAllowFromSet :: {
    sets :: { v4 :: string, v6 :: string },
    tcp :: [int]?,
    udp :: [int]?,
  } -> string
  ```

  # Arguments

  - `sets`: ipset names per family, guaranteed to exist and matched
  - `tcp` (optional): TCP destination ports
  - `udp` (optional): UDP destination ports

  # Example

  ```nix
  mkAllowFromSet {
    sets = { v4 = "geoblock4"; v6 = "geoblock6"; };
    tcp = [ 443 ];
  }
  =>
  ipset list -n geoblock4 >/dev/null 2>&1 || ipset create geoblock4 hash:net family inet
  ipset list -n geoblock6 >/dev/null 2>&1 || ipset create geoblock6 hash:net family inet6
  iptables -w -A nixos-fw -m set --match-set geoblock4 src -p tcp -m multiport --dports 443 -j nixos-fw-accept
  ip6tables -w -A nixos-fw -m set --match-set geoblock6 src -p tcp -m multiport --dports 443 -j nixos-fw-accept
  ```
*/
{ lib, ... }:
{
  sets,
  tcp ? [ ],
  udp ? [ ],
}:
let
  families = [
    {
      set = sets.v4;
      family = "inet";
      command = "iptables";
    }
    {
      set = sets.v6;
      family = "inet6";
      command = "ip6tables";
    }
  ];

  mkCreate =
    f: "ipset list -n ${f.set} >/dev/null 2>&1 || ipset create ${f.set} hash:net family ${f.family}";

  rules = import ./mkAcceptRules.nix { inherit lib; } {
    caller = "mkAllowFromSet";
    matches = lib.map (f: {
      inherit (f) command;
      match = "-m set --match-set ${f.set} src";
    }) families;
    inherit tcp udp;
  };
in
lib.throwIf (tcp == [ ] && udp == [ ])
  "mkAllowFromSet: no ports given, which would create sets nothing consults"
  (lib.concatStringsSep "\n" (lib.map mkCreate families ++ rules))
