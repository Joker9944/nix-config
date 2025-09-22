{ lib, ... }:
let
  nyx = {
    ingress = "192.168.0.128";
  };
in
{
  # redirects for temporary nyx cluster setup
  networking.hosts = {
    ${nyx.ingress} = lib.map (subdomain: "${subdomain}.vonarx.online") [
      "idm"
      "alertmanager" # cSpell:words alertmanager
      "prometheus"
      "longhorn"
      "openaudible" # cSpell:words openaudible
      "downloader"
    ];
  };
}
