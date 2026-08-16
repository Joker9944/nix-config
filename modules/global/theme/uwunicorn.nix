{ mkThemeModule, ... }:
{
  inputs,
  pkgs,
  ...
}:
mkThemeModule "uwunicorn" {
  custom.theme = {
    cursor = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
    };

    icons = {
      name = "Colloid-Dark";
      package = pkgs.colloid-icon-theme;
    };

    gtk.accent = "purple";
  };

  schemes = {
    source.scheme = {
      system = "base16";
      slug = "uwunicorn";
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
