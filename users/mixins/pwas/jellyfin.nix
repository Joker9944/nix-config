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
      url = "https://jellyfin.vonarx.online/";
    in
    lib.mkIf cfg.enable {
      enable = lib.mkDefault true;

      profiles =
        let
          ulid1 = "01KB0KV6DFPC17TBFBHNG8QHYF"; # cSpell:disable-line
          ulid2 = "01KB0KWBEA7G5M4BFEZ2T42ETH"; # cSpell:disable-line
        in
        {
          ${ulid1} = {
            inherit name;

            sites.${ulid2} = {
              inherit name url;
              manifestUrl = "${url}web/manifest.json";

              desktopEntry = {
                categories = lib.toList "AudioVideo";

                icon = pkgs.fetchurl {
                  url = "${url}web/favicons/touchicon512.png"; # cSpell:ignore favicons touchicon
                  sha256 = "sha256-SsYjD97xOjfxrt03QFEaoxXxAfqqtJ7BAsYosUYWT1U=";
                };
              };
            };
          };
        };
    };
}
