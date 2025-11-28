{ config, utility, ... }:
utility.custom.mkHyprlandModule config {
  programs.intelli-shell.settings.theme =
    let
      inherit (config.windowManager.hyprland.custom.style) pallet;
    in
    {
      primary = "default";
      secondary = "dim";
      accent = pallet.green.dull.rgb;
      comment = pallet.black.bright.rgb;
      error = "italic ${pallet.red.dull.rgb}";
      highlight = pallet.highlights.interactive.rgb;
      highlight_primary = "default";
      highlight_secondary = "dim";
      highlight_accent = "bold ${pallet.green.bright.rgb}";
      highlight_comment = "bold ${pallet.black.bright.rgb}";
    };
}
