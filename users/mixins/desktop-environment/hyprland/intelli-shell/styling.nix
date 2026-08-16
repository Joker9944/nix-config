{ mkHyprlandModule, ... }:
{ config, ... }:
mkHyprlandModule {
  programs.intelli-shell.settings.theme =
    let
      inherit (config.schemes) scheme;
      inherit (scheme) palette;
    in
    {
      primary = "default";
      secondary = "dim";
      accent = "#${scheme.green.dull.hex}";
      comment = "#${palette.base03.hex}";
      error = "italic #${scheme.red.dull.hex}";
      highlight = "#${palette.base02.hex}";
      highlight_primary = "default";
      highlight_secondary = "dim";
      highlight_accent = "bold #${scheme.green.dull.hex}";
      highlight_comment = "bold #${palette.base03.hex}";
    };
}
