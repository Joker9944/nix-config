{ mkMixinModule, ... }:
{ lib, ... }:
let
  profileId = "01KB3K8PMHDDB98J3GYDHZFZRZ"; # cSpell:disable-line
  siteId = "01KB3K8X63ANZAW0C5435Y13TC"; # cSpell:disable-line
in
mkMixinModule "audiobookshelf" {
  custom.browser-dispatcher = {
    enable = lib.mkDefault true;

    sites = [
      {
        patterns = [ "https://audiobookshelf.vonarx.online/*" ];
        command = "firefoxpwa site launch ${siteId} --url \"$URL\"";
      }
    ];
  };

  programs.firefoxpwa = {
    enable = lib.mkDefault true;

    profiles.${profileId} = {
      name = "audiobookshelf";

      sites.${siteId} = {
        name = "audiobookshelf";
        url = "https://audiobookshelf.vonarx.online/";
        manifestUrl = "https://audiobookshelf.vonarx.online/audiobookshelf/_nuxt/manifest.2f7e41c6.json"; # cSpell:ignore nuxt

        desktopEntry = {
          categories = lib.toList "AudioVideo";
          icon = ./icon.png;
        };
      };
    };
  };
}
