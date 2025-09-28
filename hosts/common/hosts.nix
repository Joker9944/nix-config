{ lib, ... }:
let
  nyx = {
    ingress = "192.168.0.128";
  };
in
{
  # redirects for temporary nyx cluster setup
  # cSpell:words alertmanager openaudible prowlarr radarr sonarr komga pgadmin
  networking.hosts = {
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
