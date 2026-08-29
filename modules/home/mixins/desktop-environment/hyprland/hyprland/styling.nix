{ mkHyprlandModule, ... }:
{ config, ... }:
let
  cfg = config.mixins.desktopEnvironment.hyprland.style;

  cursorSize = 24;
in
mkHyprlandModule {
  home.sessionVariables = {
    XCURSOR_THEME = config.schemes.cursors.name;
    XCURSOR_SIZE = cursorSize;

    HYPRCURSOR_THEME = config.schemes.cursors.name;
    # hyprcursor renders an SVG into a size*size box, and Breeze draws a nominal 24 on a
    # 32-unit canvas that 90 of its 91 shapes use the whole of. Scaling the request is the
    # only way to match XCursor, since cropping the canvas would clip the artwork.
    HYPRCURSOR_SIZE = cursorSize * 32 / 24;
  };

  wayland.windowManager.hyprland.settings =
    let
      inherit (config.schemes) scheme;
    in
    {
      config = {
        general = {
          border_size = cfg.border.size;
          gaps_in = 5;
          gaps_out = 10;

          "col.active_border" = "rgba(${scheme.accent.rgba 0.93})";
          "col.inactive_border" = "rgba(${scheme.named.background.dark.rgba 0.66})";

          layout = "dwindle";
        };

        decoration = {
          inherit (cfg.border.corners) rounding;
          rounding_power = cfg.border.corners.power;

          active_opacity = cfg.opacity.active;
          inactive_opacity = cfg.opacity.inactive;

          blur = {
            size = 4;
            xray = true;
          };

          shadow.color = "rgba(${scheme.named.background.darker.rgba 0.93})";
        };

        dwindle.preserve_split = true;

        master.new_status = "master";

        misc = {
          disable_hyprland_logo = true;
          size_limits_tiled = true; # Respect min_size and max_size rules also for tiled windows
        };
      };
    };
}
