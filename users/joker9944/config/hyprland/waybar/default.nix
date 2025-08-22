/**
  * status bar
*/
{
  lib,
  config,
  pkgs,
  pkgs-hyprland,
  utility,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
in
utility.custom.mkHyprlandModule config {
  home.packages = [ pkgs.nerd-fonts.symbols-only ];

  programs.waybar = {
    enable = true;
    package = pkgs-hyprland.waybar;

    systemd.enable = true;

    settings = import ./settings.main.nix { inherit cfg; };
    style = import ./style.css.nix { inherit cfg; };
  };

  wayland.windowManager.hyprland.settings = {
    decoration.layerrule = [
      "blur, waybar"
      "xray 1, waybar"
    ];
  };
}
