{ mkMixinModule, ... }:
{ lib, ... }:
let
  profileId = "01KB0KV6DFPC17TBFBHNG8QHYF"; # cSpell:disable-line
  siteId = "01KB0KWBEA7G5M4BFEZ2T42ETH"; # cSpell:disable-line
in
mkMixinModule "jellyfin" {
  custom.browser-dispatcher = {
    enable = lib.mkDefault true;

    sites = [
      {
        patterns = [ "https://jellyfin.vonarx.online/*" ];
        command = "firefoxpwa site launch ${siteId} --url \"$URL\"";
      }
    ];
  };

  programs.firefoxpwa = {
    enable = lib.mkDefault true;

    profiles.${profileId} = {
      name = "Jellyfin";

      sites.${siteId} = {
        name = "Jellyfin";
        url = "https://jellyfin.vonarx.online/";
        manifestUrl = "https://jellyfin.vonarx.online/web/manifest.json";

        desktopEntry = {
          categories = lib.toList "AudioVideo";
          icon = ./icon.png;
        };
      };
    };
  };
}
