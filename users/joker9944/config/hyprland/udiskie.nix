/**
  * mount daemon
*/
{
  lib,
  options,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  services = {
    udiskie = {
      enable = true;
      # TODO Not supported in release-25.05 simplify when updating to release-25.11
      #package = pkgs-hyprland.udiskie;
    };
  };
}
