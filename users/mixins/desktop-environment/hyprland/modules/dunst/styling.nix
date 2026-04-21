{ mkHyprlandModule, ... }:
{ lib, config, ... }:
let
  cfg = config.mixins.desktopEnvironment.hyprland.style;
  inherit (cfg) border icons;
  font = config.mixins.desktopEnvironment.hyprland.style.fonts.interface;
in
mkHyprlandModule {
  programs.wallust.templates.dunst = {
    enable = true;

    template = {
      global = {
        frame_color = "{{color0}}";
        separator_color = "frame";
      };

      urgency_low = {
        background = "{{background}}";
        foreground = "{{foreground}}";
      };

      urgency_normal = {
        background = "{{background}}";
        foreground = "{{foreground}}";
      };

      urgency_critical = {
        background = "{{color1}}";
        foreground = "{{color7}}";
        frame_color = "{{color1 | lighten(0.2)}}";
      };
    };
  };

  services.dunst = {
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

        ###############
        ### BORDERS ###
        ###############
        frame_width = border.size;
        corner_radius = border.corners.rounding;
      };
    };
  };
}
