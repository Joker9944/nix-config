{
  lib,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  services.dunst.settings = with config.windowManager.hyprland.custom.style; {
    global = {
      ############
      ### TEXT ###
      ############
      font = lib.mkIf (font != null) "${font.name} ${toString font.size}";

      #############
      ### ICONS ###
      #############
      min_icon_size = 0;
      max_icon_size = 128;
      icon_theme = lib.mkIf (icons != null) icons.name;

      ##############
      ### COLORS ###
      ##############
      frame_color = pallet.background.light.hex;
      separator_color = "frame";

      ###############
      ### BORDERS ###
      ###############
      frame_width = border.size;
      corner_radius = border.corners.rounding;
    };

    urgency_low = {
      background = pallet.background.normal.hex;
      foreground = pallet.foreground.hex;
    };

    urgency_normal = {
      background = pallet.background.normal.hex;
      foreground = pallet.foreground.hex;
    };

    urgency_critical = {
      background = pallet.red.dull.hex;
      foreground = pallet.white.dull.hex;
      frame_color = pallet.red.dull.hex;
    };
  };
}
