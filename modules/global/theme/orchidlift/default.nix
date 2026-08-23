{ flake, mkThemeModule, ... }:
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  libSchemes = inputs.nix-schemes.lib.libSchemes;

  mkOrchidliftTheme =
    variant:
    {
      accent,
      palette,
    }:
    mkThemeModule "orchidlift-${variant}" {
      custom.theme = {
        inherit accent;

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

        icons = {
          name = "Tela-circle-dark";
          base = pkgs.tela-circle-icon-theme;
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
