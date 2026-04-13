{ mkDefaultHyprlandModule, ... }:
{ config, pkgs-hyprland, ... }:
mkDefaultHyprlandModule
  {
    dir = ./.;
    exclude = [ ./files ];
  }
  {
    config.services.dunst =
      let
        cfg = config.mixins.desktopEnvironment.hyprland;
      in
      {
        enable = true;
        package = pkgs-hyprland.dunst;

        settings = {
          global = {
            ### Display ###

            follow = "mouse";
            enable_posix_regex = true;

            ### Geometry ###

            width = 500;
            height = "(0, 300)";

            origin = "top-center";
            offset = "(0, 20)";

            notification_limit = 5;

            ### Misc/Advanced ###

            dmenu = cfg.launcher.mkDmenuCommand { };

            ### Actions ###

            mouse_left_click = "do_action, close_current";
            mouse_middle_click = "none";
            mouse_right_click = "close_all";
          };
        };
      };
  }
