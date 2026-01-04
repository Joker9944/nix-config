{
  lib,
  config,
  custom,
  ...
}:
custom.lib.mkHyprlandModule config {
  services.dunst =
    let
      cfg = config.windowManager.hyprland.custom.style;
      inherit (cfg) border icons scheme;
      font = config.windowManager.hyprland.custom.style.fonts.interface;
    in
    {
      iconTheme = icons;

      settings = {
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
          enable_recursive_icon_lookup = true;

          ##############
          ### COLORS ###
          ##############
          frame_color = scheme.background.light.hex;
          separator_color = "frame";

          ###############
          ### BORDERS ###
          ###############
          frame_width = border.size;
          corner_radius = border.corners.rounding;
        };

        urgency_low = {
          background = scheme.background.normal.hex;
          foreground = scheme.foreground.normal.hex;
        };

        urgency_normal = {
          background = scheme.background.normal.hex;
          foreground = scheme.foreground.normal.hex;
        };

        urgency_critical = {
          background = scheme.red.dull.hex;
          foreground = scheme.white.dull.hex;
          frame_color = scheme.red.bright.hex;
        };
      };
    };
}
