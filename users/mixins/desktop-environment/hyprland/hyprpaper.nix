{
  lib,
  config,
  pkgs-hyprland,
  custom,
  ...
}:
let
  wallpaper = "${custom.assets.dracula-leaves-dark}/share/backgrounds/dracula-leaves-dark.png";
in
custom.lib.mkHyprlandModule config {
  services.hyprpaper = {
    enable = true;
    package = pkgs-hyprland.hyprpaper;

    settings = lib.mkDefault {
      splash = false;

      wallpaper = [
        {
          monitor = "";
          path = wallpaper;
        }
      ];
    };
  };
}
