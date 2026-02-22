{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.pwas.audiobookshelf =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "audiobookshelf PWA config mixin";

      name = mkOption {
        type = types.str;
        default = "audiobookshelf";
      };

      urlBase = mkOption {
        type = types.str;
        default = "https://audiobookshelf.vonarx.online";
      };

      profileId = mkOption {
        type = types.str;
        default = "01KB3K8PMHDDB98J3GYDHZFZRZ"; # cSpell:disable-line
      };

      siteId = mkOption {
        type = types.str;
        default = "01KB3K8X63ANZAW0C5435Y13TC"; # cSpell:disable-line
      };
    };

  config =
    let
      cfg = config.mixins.pwas.audiobookshelf;
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
            manifestUrl = "${cfg.urlBase}/audiobookshelf/_nuxt/manifest.2f7e41c6.json"; # cSpell:ignore nuxt

            desktopEntry = {
              categories = lib.toList "AudioVideo";

              icon = pkgs.fetchurl {
                url = "${cfg.urlBase}/audiobookshelf/icon192.png";
                sha256 = "sha256-+E8xQ09ODEtFJyKVdPDJR6RDQx2UQDzXTOQXtWa2pvM=";
              };
            };
          };
        };
      };
    };
}
