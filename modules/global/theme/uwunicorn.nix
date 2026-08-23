{ mkThemeModule, ... }:
{
  inputs,
  pkgs,
  ...
}:
mkThemeModule "uwunicorn" {
  custom.theme.gtk.accent = "purple";

  schemes = {
    source.scheme = {
      system = "base16";
      slug = "uwunicorn";
    };

    icons = {
      name = "Colloid-Dark";
      base = pkgs.colloid-icon-theme;
    };

    transformers =
      let
        schemeTransformers = inputs.nix-schemes.lib.libSchemes.transformers;
      in
      [
        (schemeTransformers.interpolateBase24 { })
        schemeTransformers.named
        schemeTransformers.ansi
      ];
  };
}
