{
  lib,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  imports = (utility.custom.ls.lookup {
    dir = ./.;
    exclude = [./default.nix];
  });

  config = lib.mkIf config.desktopEnvironment.hyprland.enable {
    wayland = {
      systemd.target = lib.mkIf config.wayland.windowManager.hyprland.systemd.enable "hyprland-session.target";

      windowManager.hyprland = {
        enable = true;

        # Hyprland installed trough NixOS
        package = null;
        portalPackage = null;
      };
    };
  };
}
