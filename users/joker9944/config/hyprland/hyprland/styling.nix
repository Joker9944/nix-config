{
  lib,
  config,
  utility,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
in
utility.custom.mkHyprlandModule config {
  wayland.windowManager.hyprland.settings = with cfg.style; {
    # Environment variables
    # https://wiki.hyprland.org/Configuring/Environment-variables/
    env = lib.attrsets.mapAttrsToList (name: value: name + ", " + (toString value)) {
      "XCURSOR_THEME" = config.gtk.cursorTheme.name;
      "XCURSOR_SIZE" = if config.gtk.cursorTheme.size != null then config.gtk.cursorTheme.size else 16;
    };

    general = {
      border_size = border.size;
      gaps_in = 5;
      gaps_out = 10;

      # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
      #"col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.active_border" = pallet.functional.focus.rgba 0.93;
      "col.inactive_border" = pallet.background.dark.rgba 0.66;

      layout = "dwindle";
    };

    # https://wiki.hyprland.org/Configuring/Variables/#decoration
    decoration = {
      inherit (border.corners) rounding;
      rounding_power = border.corners.power;

      # Change transparency of focused and unfocused windows
      active_opacity = opacity.active;
      inactive_opacity = opacity.inactive;

      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = pallet.background.darker.rgba 0.93;
      };

      # https://wiki.hyprland.org/Configuring/Variables/#blur
      blur = {
        enabled = true;
        size = 4;

        xray = true;

        vibrancy = 0.1696;
      };
    };

    # https://wiki.hyprland.org/Configuring/Variables/#animations
    animations = {
      enabled = "yes, please :)";

      # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      bezier = [
        "easeOutQuint,0.23,1,0.32,1"
        "easeInOutCubic,0.65,0.05,0.36,1"
        "linear,0,0,1,1"
        "almostLinear,0.5,0.5,0.75,1.0"
        "quick,0.15,0,0.1,1"
      ];

      animation = [
        "global, 1, 10, default"
        "border, 1, 5.39, easeOutQuint"
        "windows, 1, 4.79, easeOutQuint"
        "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
        "windowsOut, 1, 1.49, linear, popin 87%"
        "fadeIn, 1, 1.73, almostLinear"
        "fadeOut, 1, 1.46, almostLinear"
        "fade, 1, 3.03, quick"
        "layers, 1, 3.81, easeOutQuint"
        "layersIn, 1, 4, easeOutQuint, fade"
        "layersOut, 1, 1.5, linear, fade"
        "fadeLayersIn, 1, 1.79, almostLinear"
        "fadeLayersOut, 1, 1.39, almostLinear"
        "workspaces, 1, 1.94, almostLinear, fade"
        "workspacesIn, 1, 1.21, almostLinear, fade"
        "workspacesOut, 1, 1.94, almostLinear, fade"
      ];
    };

    # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
    # "Smart gaps" / "No gaps when only"
    # uncomment all if you wish to use that.
    # workspace = w[tv1], gapsout:0, gapsin:0
    # workspace = f[1], gapsout:0, gapsin:0
    # windowrule = bordersize 0, floating:0, onworkspace:w[tv1]
    # windowrule = rounding 0, floating:0, onworkspace:w[tv1]
    # windowrule = bordersize 0, floating:0, onworkspace:f[1]
    # windowrule = rounding 0, floating:0, onworkspace:f[1]

    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    master = {
      new_status = "master";
    };

    # https://wiki.hyprland.org/Configuring/Variables/#misc
    misc = {
      disable_hyprland_logo = true;
      background_color = cfg.style.pallet.background.normal.rgb;
    };
  };
}
