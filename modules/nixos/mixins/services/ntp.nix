{ mkMixinModule, ... }:
let
  timeServers = [
    "0.ch.pool.ntp.org"
    "1.ch.pool.ntp.org"
    "2.ch.pool.ntp.org"
    "3.ch.pool.ntp.org"
  ];
in
mkMixinModule "ntp" {
  networking.timeServers = timeServers;
  services.timesyncd.servers = timeServers;
}
