/**
  Render `networking.firewall.extraCommands` that accept the given ports only from
  the given source addresses.

  NixOS' iptables backend interpolates `extraCommands` into the firewall start
  script after the `allowedTCPPorts` accepts and before the catch-all
  `nixos-fw-log-refuse` jump, so appending to `nixos-fw` here lands in the right
  place. Three invariants follow from that script and are why this is a helper:
  the rule appends to `nixos-fw`, jumps to `nixos-fw-accept` rather than `ACCEPT`,
  and takes `-w` for the xtables lock. Rules are IPv4 only.

  One `-m multiport` rule is emitted per source and protocol, which caps each
  protocol at multiport's 15 ports.

  # Type

  ```
  mkAllowFrom :: {
    sources :: [string],
    tcp :: [int]?,
    udp :: [int]?,
  } -> string
  ```

  # Arguments

  - `sources`: Source addresses or CIDRs allowed to reach the ports
  - `tcp` (optional): TCP destination ports
  - `udp` (optional): UDP destination ports

  # Example

  ```nix
  mkAllowFrom {
    sources = [ "192.168.0.21" "10.42.0.0/16" ];
    tcp = [ 9100 10249 ];
  }
  =>
  iptables -w -A nixos-fw -s 192.168.0.21 -p tcp -m multiport --dports 9100,10249 -j nixos-fw-accept
  iptables -w -A nixos-fw -s 10.42.0.0/16 -p tcp -m multiport --dports 9100,10249 -j nixos-fw-accept
  ```
*/
{ lib, ... }:
{
  sources,
  tcp ? [ ],
  udp ? [ ],
}:
let
  mkRules =
    proto: ports:
    lib.optionals (ports != [ ]) (
      lib.throwIf (lib.length ports > 15)
        "mkAllowFrom: ${proto} port list exceeds multiport's limit of 15: ${toString ports}"
        (
          lib.map (
            source:
            "iptables -w -A nixos-fw -s ${source} -p ${proto} -m multiport --dports ${
              lib.concatMapStringsSep "," toString ports
            } -j nixos-fw-accept"
          ) sources
        )
    );
in
lib.throwIf (sources == [ ]) "mkAllowFrom: sources is empty, which would open nothing" (
  lib.concatStringsSep "\n" (mkRules "tcp" tcp ++ mkRules "udp" udp)
)
