{ mkMixinModule, ... }:
{ lib, ... }:
let
  nyx = {
    ingress = "192.168.0.128";
  };
in
mkMixinModule "hosts" {
  networking.hosts = {
    # redirects for temporary nyx cluster setup
    # cSpell:words alertmanager openaudible prowlarr radarr sonarr komga pgadmin
    ${nyx.ingress} = lib.map (subdomain: "${subdomain}.vonarx.online") [
      "idm"
      "alertmanager"
      "prometheus"
      "longhorn"
      "openaudible"
      "downloader"
      "pgadmin"
    ];
  };
}
