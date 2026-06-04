{ mkHyprlandModule, ... }:
{ config, ... }:
let
  cfg = config.mixins.desktopEnvironment.hyprland.style;
in
mkHyprlandModule {
  home.sessionVariables = {
    XCURSOR_THEME = cfg.xCursor.name;
    XCURSOR_SIZE = if cfg.xCursor.size != null then cfg.xCursor.size else 16;
  };

  wayland.windowManager.hyprland.settings =
    let
      inherit (cfg) scheme;
    in
    {
      config = {
        general = {
          border_size = cfg.border.size;
          gaps_in = 5;
          gaps_out = 10;

          "col.active_border" = "rgba(${scheme.accent.rgba 0.93})";
          "col.inactive_border" = "rgba(${scheme.background.dark.rgba 0.66})";

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

          shadow.color = "rgba(${scheme.background.darker.rgba 0.93})";
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
