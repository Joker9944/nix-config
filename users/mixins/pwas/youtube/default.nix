{ mkMixinModule, ... }:
{ lib, ... }:
let
  profileId = "01KB54CQQK7ANC7TYFXA3FT798"; # cSpell:disable-line
  siteId = "01KB54CYBGYG8ANKD8AR4C50Z8"; # cSpell:disable-line
in
mkMixinModule "youtube" {
  custom.browser-dispatcher = {
    enable = lib.mkDefault true;

    sites = [
      {
        patterns = [
          "https://youtube.com/*"
          "https://*.youtube.com/*"
          "https://youtu.be/*"
        ];
        command = "firefoxpwa site launch ${siteId} --url \"$URL\"";
      }
    ];
  };

  programs.firefoxpwa = {
    enable = lib.mkDefault true;

    profiles.${profileId} = {
      name = "YouTube";

      sites.${siteId} = {
        name = "YouTube";
        url = "https://www.youtube.com/";
        manifestUrl = "https://www.youtube.com/manifest.webmanifest";

        desktopEntry = {
          categories = lib.toList "AudioVideo";
          icon = ./icon.png;
        };
      };
    };
  };
}
