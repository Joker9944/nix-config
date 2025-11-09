/**
  * mount daemon
*/
{
  pkgs-hyprland,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  home.packages = [ pkgs-hyprland.udiskie ];

  services = {
    udiskie = {
      enable = true;
      # TODO Not supported in release-25.05 simplify when updating to release-25.11
      #package = pkgs-hyprland.udiskie;

      tray = "never";
    };
  };
}
