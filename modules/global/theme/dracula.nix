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
        draculaAnsi =
          _: colorLib:
          let
            mkColorFromHex = hex: colorLib.mkColor (colorLib.fromHex hex);
          in
          {
            ansi = {
              "0" = mkColorFromHex "#21222C";
              "8" = mkColorFromHex "#6272A4";
              "1" = mkColorFromHex "#FF5555";
              "9" = mkColorFromHex "#FF6E6E";
              "2" = mkColorFromHex "#50FA7B";
              "A" = mkColorFromHex "#69FF94";
              "3" = mkColorFromHex "#F1FA8C";
              "B" = mkColorFromHex "#FFFFA5";
              "4" = mkColorFromHex "#BD93F9";
              "C" = mkColorFromHex "#D6ACFF";
              "5" = mkColorFromHex "#FF79C6";
              "D" = mkColorFromHex "#FF92DF";
              "6" = mkColorFromHex "#8BE9FD";
              "E" = mkColorFromHex "#A4FFFF";
              "7" = mkColorFromHex "#F8F8F2";
              "F" = mkColorFromHex "#FFFFFF";
            };
          };
        schemeTransformers = inputs.nix-schemes.lib.libSchemes.transformers;
      in
      [
        schemeTransformers.named
        draculaAnsi
      ];
  };
}
