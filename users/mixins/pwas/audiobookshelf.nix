{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.pwas.audiobookshelf =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "audiobookshelf PWA config mixin";
    };

  config.programs.firefoxpwa =
    let
      cfg = config.mixins.pwas.audiobookshelf;
      name = "audiobookshelf";
      urlBase = "https://audiobookshelf.vonarx.online";
      ulid1 = "01KB3K8PMHDDB98J3GYDHZFZRZ"; # cSpell:disable-line
      ulid2 = "01KB3K8X63ANZAW0C5435Y13TC"; # cSpell:disable-line
    in
    lib.mkIf cfg.enable {
      enable = lib.mkDefault true;

      profiles.${ulid1} = {
        inherit name;

        sites.${ulid2} = {
          inherit name;
          url = "${urlBase}/";
          manifestUrl = "${urlBase}/audiobookshelf/_nuxt/manifest.2f7e41c6.json"; # cSpell:ignore nuxt

          desktopEntry = {
            categories = lib.toList "AudioVideo";

            icon = pkgs.fetchurl {
              url = "${urlBase}/audiobookshelf/icon192.png";
              sha256 = "sha256-+E8xQ09ODEtFJyKVdPDJR6RDQx2UQDzXTOQXtWa2pvM=";
            };
          };
        };
      };
    };
}
