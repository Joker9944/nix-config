{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.pwas.youtube =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "youtube PWA config mixin";
    };

  config.programs.firefoxpwa =
    let
      cfg = config.mixins.pwas.youtube;
      name = "YouTube";
      urlBase = "https://www.youtube.com";
      ulid1 = "01KB54CQQK7ANC7TYFXA3FT798"; # cSpell:disable-line
      ulid2 = "01KB54CYBGYG8ANKD8AR4C50Z8"; # cSpell:disable-line
    in
    lib.mkIf cfg.enable {
      enable = lib.mkDefault true;

      profiles.${ulid1} = {
        inherit name;

        sites.${ulid2} = {
          inherit name;
          url = "${urlBase}/";
          manifestUrl = "${urlBase}/manifest.webmanifest";

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
}
