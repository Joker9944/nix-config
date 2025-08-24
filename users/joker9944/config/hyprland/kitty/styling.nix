{
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  programs.kitty.settings = with config.windowManager.hyprland.custom.style; {
    cursor_shape = "beam";

    cursor = pallet.cursor.hex;
    background = pallet.background.normal.hex;
    foreground = pallet.foreground.hex;

    color0 = pallet.black.dull.hex;
    color8 = pallet.black.bright.hex;
    color1 = pallet.red.dull.hex;
    color9 = pallet.red.bright.hex;
    color2 = pallet.green.dull.hex;
    color10 = pallet.green.bright.hex;
    color3 = pallet.yellow.dull.hex;
    color11 = pallet.yellow.bright.hex;
    color4 = pallet.blue.dull.hex;
    color12 = pallet.blue.bright.hex;
    color5 = pallet.magenta.dull.hex;
    color13 = pallet.magenta.bright.hex;
    color6 = pallet.cyan.dull.hex;
    color14 = pallet.cyan.bright.hex;
    color7 = pallet.white.dull.hex;
    color15 = pallet.white.bright.hex;
  };
}
