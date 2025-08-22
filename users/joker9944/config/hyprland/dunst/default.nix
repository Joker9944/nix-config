{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}: let
  cfg = config.desktopEnvironment.hyprland;
in
  utility.custom.mkHyprlandModule config {
    imports = utility.custom.ls.lookup {
      dir = ./.;
      exclude = [./default.nix];
    };

    config.services.dunst = {
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
        };
      };
    };
  }
