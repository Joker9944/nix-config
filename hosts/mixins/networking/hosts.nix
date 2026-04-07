{ lib, config, ... }:
let
  nyx = {
    ingress = "192.168.0.128";
  };
in
{
  options.mixins.networking.hosts =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "hosts config mixin";
    };

  config.networking.hosts =
    let
      cfg = config.mixins.networking.hosts;
    in
    lib.mkIf cfg.enable {
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
