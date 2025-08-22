{
  config,
  utility,
  ...
}: let
  cfg = config.desktopEnvironment.hyprland;
in
  utility.custom.mkHyprlandModule config {
    services.dunst.settings = with cfg.style; {
      global = {
        ############
        ### TEXT ###
        ############
        font = "${cfg.style.font.name} ${toString cfg.style.font.size}";

        #############
        ### ICONS ###
        #############
        min_icon_size = 0;
        max_icon_size = 128;
        icon_theme = cfg.style.iconTheme.name;

        ##############
        ### COLORS ###
        ##############
        frame_color = pallet.background.light.hex;
        separator_color = "frame";

        ###############
        ### BORDERS ###
        ###############
        frame_width = cfg.style.border.size;
        corner_radius = cfg.style.border.corners.rounding;
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
