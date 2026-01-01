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
          frame_color = scheme.named.background.light.hex;
          separator_color = "frame";

          ###############
          ### BORDERS ###
          ###############
          frame_width = border.size;
          corner_radius = border.corners.rounding;
        };

        urgency_low = {
          background = scheme.named.background.normal.hex;
          foreground = scheme.named.foreground.normal.hex;
        };

        urgency_normal = {
          background = scheme.named.background.normal.hex;
          foreground = scheme.named.foreground.normal.hex;
        };

        urgency_critical = {
          background = scheme.named.red.dull.hex;
          foreground = scheme.named.white.dull.hex;
          frame_color = scheme.named.red.bright.hex;
        };
      };
    };
}
