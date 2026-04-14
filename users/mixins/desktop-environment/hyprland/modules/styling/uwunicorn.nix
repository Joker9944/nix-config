{ mkHyprlandModule, ... }:
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
mkHyprlandModule {
  config =
    let
      cfg = config.mixins.desktopEnvironment.hyprland.style;
    in
    lib.mkIf (cfg.theme == "uwunicorn") {
      mixins.desktopEnvironment.hyprland.style = {
        xCursor = {
          name = "breeze_cursors";
          package = pkgs.kdePackages.breeze;
        };

        icons = {
          name = "Colloid";
          package = pkgs.colloid-icon-theme;
        };
      };

      schemes = {
        source.scheme = {
          system = "base16";
          slug = "uwunicorn";
        };

        transformers =
          let
            schemeTransformers = inputs.nix-schemes.lib.transformers;
          in
          [
            (schemeTransformers.interpolateBase24 { })
            schemeTransformers.named
            schemeTransformers.ansi
            config.schemes.gtk.accentTransformer
          ];

        gtk.accent = "purple";
      };
    };
}
