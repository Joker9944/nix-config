{ mkMixinModule, ... }:
{ lib, ... }:
let
  nyx = {
    ingress = "192.168.0.128";
  };
in
mkMixinModule "hosts" {
  networking.hosts = {
    # labels absent from public DNS, reachable only through the VPN via the cluster ingress
    # cSpell:words alertmanager openaudible prowlarr radarr sonarr komga pgadmin
    ${nyx.ingress} = lib.map (subdomain: "${subdomain}.vonarx.online") [
      "alertmanager"
      "prometheus"
      "longhorn"
      "openaudible"
      "downloader"
      "pgadmin"
    ];
  };
}
