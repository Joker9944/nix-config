/**
  Render `networking.firewall.extraCommands` that accept the given ports only from
  the given source addresses.

  Rules are IPv4 only, one `-m multiport` per source and protocol; the
  `nixos-fw` invariants and the 15-port cap live in `mkAcceptRules.nix`.

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
lib.throwIf (sources == [ ]) "mkAllowFrom: sources is empty, which would open nothing" (
  lib.concatStringsSep "\n" (
    import ./mkAcceptRules.nix { inherit lib; } {
      caller = "mkAllowFrom";
      matches = lib.map (source: {
        command = "iptables";
        match = "-s ${source}";
      }) sources;
      inherit tcp udp;
    }
  )
)
