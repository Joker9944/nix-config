{ mkThemeModule, ... }:
{
  inputs,
  pkgs,
  ...
}:
mkThemeModule "dracula" {
  custom.theme = {
    cursor = {
      name = "Dracula-cursors";
      package = pkgs.dracula-theme;
    };

    icons = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };

    accent = "#815CD6";

    gtk.accent = "purple";
  };

  schemes = {
    source.scheme = {
      system = "base24";
      slug = "dracula";
    };

    transformers =
      let
        # Dracula ships an ANSI black distinct from its background; the scheme parks it in
        # base01, where the spec puts base00. Every other slot derives from the spec.
        draculaAnsi = scheme: _: {
          ansi."0" = scheme.palette.base01;
        };
        schemeTransformers = inputs.nix-schemes.lib.libSchemes.transformers;
      in
      [
        schemeTransformers.named
        schemeTransformers.ansi
        draculaAnsi
      ];
  };
}
