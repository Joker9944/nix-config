{ mkHyprlandModule, ... }:
{ config, ... }:
mkHyprlandModule {
  programs.intelli-shell.settings.theme =
    let
      inherit (config.mixins.desktopEnvironment.hyprland.style) scheme;
      inherit (config.mixins.desktopEnvironment.hyprland.style.scheme) palette;
    in
    {
      primary = "default";
      secondary = "dim";
      accent = scheme.green.dull.rgb;
      comment = palette.base03.rgb;
      error = "italic ${scheme.red.dull.rgb}";
      highlight = palette.base02.rgb;
      highlight_primary = "default";
      highlight_secondary = "dim";
      highlight_accent = "bold ${scheme.green.dull.rgb}";
      highlight_comment = "bold ${palette.base03.rgb}";
    };
}
