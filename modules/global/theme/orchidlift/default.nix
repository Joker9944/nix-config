{ flake, mkThemeModule, ... }:
{
  lib,
  pkgs,
  ...
}:
let
  mkOrchidliftTheme =
    variant:
    {
      accent,
      palette,
    }:
    mkThemeModule "orchidlift-${variant}" {
      custom.theme = {
        inherit accent;

        gtk = {
          accent = "purple";
          uniformAccents = true;
        };
      };

      schemes = {
        source.custom = {
          name = "ORCHIDLIFT ${lib.toUpper variant}";
          author = "Joker9944 (https://github.com/Joker9944)";
          variant = "dark";

          inherit palette;
        };

        icons = {
          name = "Tela-circle-dark";
          base = pkgs.tela-circle-icon-theme;
        };
      };
    };
in
flake.lib.modules.mkDefaultModule {
  dir = ./.;
  args = { inherit mkOrchidliftTheme; };
} { }
