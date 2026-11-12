/**
  Private builder behind `mkAllowFrom` and `mkAllowFromSet`; excluded from the
  `network` namespace in `default.nix`.

  NixOS' iptables backend interpolates `extraCommands` into the firewall start
  script after the `allowedTCPPorts` accepts and before the catch-all
  `nixos-fw-log-refuse` jump, so appending to `nixos-fw` here lands in the right
  place. Three invariants follow from that script and are why this exists: the
  rule appends to `nixos-fw`, jumps to `nixos-fw-accept` rather than `ACCEPT`,
  and takes `-w` for the xtables lock.

  One `-m multiport` rule is emitted per protocol and match, which caps each
  protocol at multiport's 15 ports.

  # Type

  ```
  mkAcceptRules :: {
    caller :: string,
    matches :: [{ command :: string, match :: string }],
    tcp :: [int]?,
    udp :: [int]?,
  } -> [string]
  ```

  # Example

  ```nix
  mkAcceptRules {
    caller = "mkAllowFrom";
    matches = [ { command = "iptables"; match = "-s 10.0.0.1"; } ];
    tcp = [ 22 ];
  }
  =>
  [ "iptables -w -A nixos-fw -s 10.0.0.1 -p tcp -m multiport --dports 22 -j nixos-fw-accept" ]
  ```
*/
{ lib, ... }:
{
  caller,
  matches,
  tcp ? [ ],
  udp ? [ ],
}:
let
  mkRules =
    proto: ports:
    lib.optionals (ports != [ ]) (
      lib.throwIf (lib.length ports > 15)
        "${caller}: ${proto} port list exceeds multiport's limit of 15: ${toString ports}"
        (
          lib.map (
            m:
            "${m.command} -w -A nixos-fw ${m.match} -p ${proto} -m multiport --dports ${
              lib.concatMapStringsSep "," toString ports
            } -j nixos-fw-accept"
          ) matches
        )
    );
in
mkRules "tcp" tcp ++ mkRules "udp" udp
