{ flake, mkThemeModule, ... }:
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  libSchemes = inputs.nix-schemes.lib.libSchemes;

  defaultCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
  };

  defaultIcons = {
    name = "Colloid-Dark";
    package = pkgs.colloid-icon-theme;
  };

  mkOrchidliftTheme =
    variant:
    {
      accent,
      palette,
      cursor ? defaultCursor,
      icons ? defaultIcons,
    }:
    mkThemeModule "orchidlift-${variant}" {
      custom.theme = {
        inherit accent cursor icons;

        gtk.accent = "purple";
      };

      schemes = {
        source.override = libSchemes.color.mkScheme {
          system = "base24";
          name = "ORCHIDLIFT ${lib.toUpper variant}";
          author = "Joker9944 (https://github.com/Joker9944)";
          variant = "dark";

          palette = lib.mapAttrs (_: hex: libSchemes.color.mkColor (libSchemes.color.fromHex hex)) palette;
        };

        transformers = [
          libSchemes.transformers.named
          libSchemes.transformers.ansi
        ];
      };
    };
in
flake.lib.modules.mkDefaultModule {
  dir = ./.;
  args = { inherit mkOrchidliftTheme; };
} { }
