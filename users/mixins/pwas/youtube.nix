{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.pwas.youtube =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "youtube PWA config mixin";

      name = mkOption {
        type = types.str;
        default = "YouTube";
      };

      urlBase = mkOption {
        type = types.str;
        default = "https://www.youtube.com";
      };

      profileId = mkOption {
        type = types.str;
        default = "01KB54CQQK7ANC7TYFXA3FT798"; # cSpell:disable-line
      };

      siteId = mkOption {
        type = types.str;
        default = "01KB54CYBGYG8ANKD8AR4C50Z8"; # cSpell:disable-line
      };
    };

  config =
    let
      cfg = config.mixins.pwas.youtube;
    in
    lib.mkIf cfg.enable {
      custom.browser-dispatcher = {
        enable = lib.mkDefault true;

        sites = [
          {
            path = "https://*.youtube.com/*|https://youtu.be/*";
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
            manifestUrl = "${cfg.urlBase}/manifest.webmanifest";

            desktopEntry = {
              categories = lib.toList "AudioVideo";

              icon = pkgs.fetchurl {
                url = "https://www.gstatic.com/youtube/img/web/maskable/logo_512x512.png";
                sha256 = "sha256-RjFUv8vDu8d7ZKS1glpswUM3fyQixXVoa+FocdOnphU=";
              };
            };
          };
        };
      };
    };
}
