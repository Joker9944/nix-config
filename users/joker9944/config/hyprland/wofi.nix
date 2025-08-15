/**
* Covers:
*  - app launcher
*  - clipboard history
*/
{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  home.packages = [pkgs-hyprland.wl-clipboard]; # Wayland clipboard utilities

  services.cliphist = {
    enable = true;
    package = pkgs-hyprland.cliphist;
  };

  programs.wofi = {
    enable = true;
    package = pkgs-hyprland.wofi;
  };

  wayland.windowManager.hyprland.settings = {
    "$menu" = "wofi --show drun";
    "$clipboardMenu" = "cliphist list | wofi --dmenu | cliphist decode | wl-copy";

    exec-once = [
      "wl-paste --type text --watch cliphist store"
    ];

    bindr = [
      "$mainMod, SUPER_L, exec, pkill wofi || $menu" # TODO find a way to not ref wofi directly.
    ];

    bind = [
      "$mainMod, R, exec, $menu"
      "$mainMod CTRL, V, exec, $clipboard"
    ];
  };
}
