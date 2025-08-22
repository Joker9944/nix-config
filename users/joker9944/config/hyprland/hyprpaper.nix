/**
* wallpaper management daemon
*/
{
  config,
  pkgs-hyprland,
  utility,
  custom,
  ...
}: let
  wallpaper = "${custom.assets.images.backgrounds.dracula-leaves-dark.${custom.config.resolution}}/share/backgrounds/dracula-leaves-dark.${custom.config.resolution}.png";
in
  utility.custom.mkHyprlandModule config {
    services.hyprpaper = {
      enable = true;
      package = pkgs-hyprland.hyprpaper;

      settings = {
        preload = [wallpaper];

        wallpaper = [", ${wallpaper}"];
      };
    };
  }
