{ config, custom, ... }:
custom.lib.mkHyprlandModule config {
  programs.intelli-shell.settings.theme =
    let
      inherit (config.windowManager.hyprland.custom.style) scheme;
      inherit (config.windowManager.hyprland.custom.style.scheme) palette;
    in
    {
      primary = "default";
      secondary = "dim";
      accent = scheme.named.green.dull.rgb;
      comment = palette.base03.rgb;
      error = "italic ${scheme.named.red.dull.rgb}";
      highlight = palette.base02.rgb;
      highlight_primary = "default";
      highlight_secondary = "dim";
      highlight_accent = "bold ${scheme.named.green.dull.rgb}";
      highlight_comment = "bold ${palette.base03.rgb}";
    };
}
