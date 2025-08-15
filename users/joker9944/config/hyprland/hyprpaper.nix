/**
* wallpaper management daemon
*/
{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  services.hyprpaper = {
    enable = true;
    package = pkgs-hyprland.hyprpaper;
  };
}
