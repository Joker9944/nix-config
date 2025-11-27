{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.pwas.jellyfin =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "jellyfin PWA config mixin";
    };

  config.programs.firefoxpwa =
    let
      cfg = config.mixins.pwas.jellyfin;
      name = "Jellyfin";
      urlBase = "https://jellyfin.vonarx.online";
      ulid1 = "01KB0KV6DFPC17TBFBHNG8QHYF"; # cSpell:disable-line
      ulid2 = "01KB0KWBEA7G5M4BFEZ2T42ETH"; # cSpell:disable-line
    in
    lib.mkIf cfg.enable {
      enable = lib.mkDefault true;

      profiles.${ulid1} = {
        inherit name;

        sites.${ulid2} = {
          inherit name;
          url = "${urlBase}/";
          manifestUrl = "${urlBase}/web/manifest.json";

          desktopEntry = {
            categories = lib.toList "AudioVideo";

            icon = pkgs.fetchurl {
              url = "${urlBase}/web/favicons/touchicon512.png"; # cSpell:ignore favicons touchicon
              sha256 = "sha256-SsYjD97xOjfxrt03QFEaoxXxAfqqtJ7BAsYosUYWT1U=";
            };
          };
        };
      };
    };
}
