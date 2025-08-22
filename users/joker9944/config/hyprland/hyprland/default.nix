{
  lib,
  config,
  utility,
  ...
}: let
  cfg = config.wayland.windowManager.hyprland;
in
  utility.custom.mkHyprlandModule config {
    imports = utility.custom.ls.lookup {
      dir = ./.;
      exclude = [./default.nix];
    };

    config.wayland = {
      systemd.target = lib.mkIf cfg.systemd.enable "hyprland-session.target";

      windowManager.hyprland = {
        enable = true;

        # Hyprland installed trough NixOS
        package = null;
        portalPackage = null;
      };
    };
  }
