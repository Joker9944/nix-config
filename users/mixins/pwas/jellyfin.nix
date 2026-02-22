{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.pwas.jellyfin =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "jellyfin PWA config mixin";

      name = mkOption {
        type = types.str;
        default = "Jellyfin";
      };

      urlBase = mkOption {
        type = types.str;
        default = "https://jellyfin.vonarx.online";
      };

      profileId = mkOption {
        type = types.str;
        default = "01KB0KV6DFPC17TBFBHNG8QHYF"; # cSpell:disable-line
      };

      siteId = mkOption {
        type = types.str;
        default = "01KB0KWBEA7G5M4BFEZ2T42ETH"; # cSpell:disable-line
      };
    };

  config =
    let
      cfg = config.mixins.pwas.jellyfin;
    in
    lib.mkIf cfg.enable {
      custom.browser-dispatcher = {
        enable = lib.mkDefault true;

        sites = [
          {
            patterns = [ "${cfg.urlBase}/*" ];
            command = "firefoxpwa site launch ${cfg.siteId} --url \"$URL\"";
          }
        ];
      };

      programs.firefoxpwa = {
        enable = lib.mkDefault true;

        profiles.${cfg.profileId} = {
          inherit (cfg) name;

          sites.${cfg.siteId} = {
            inherit (cfg) name;
            url = "${cfg.urlBase}/";
            manifestUrl = "${cfg.urlBase}/web/manifest.json";

            desktopEntry = {
              categories = lib.toList "AudioVideo";

              icon = pkgs.fetchurl {
                url = "${cfg.urlBase}/web/favicons/touchicon512.png"; # cSpell:ignore favicons touchicon
                sha256 = "sha256-SsYjD97xOjfxrt03QFEaoxXxAfqqtJ7BAsYosUYWT1U=";
              };
            };
          };
        };
      };
    };
}
