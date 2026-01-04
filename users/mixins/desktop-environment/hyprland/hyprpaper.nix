/**
  * wallpaper management daemon
*/
{
  lib,
  config,
  pkgs-hyprland,
  custom,
  ...
}:
let
  wallpaper = "${
    custom.assets.images.backgrounds.dracula-leaves-dark.${custom.config.resolution}
  }/share/backgrounds/dracula-leaves-dark.${custom.config.resolution}.png";
in
custom.lib.mkHyprlandModule config {
  services.hyprpaper = {
    enable = true;
    package = pkgs-hyprland.hyprpaper;

    settings = lib.mkDefault {
      wallpaper = [
        {
          monitor = "";
          path = wallpaper;
        }
      ];
    };
  };
}
