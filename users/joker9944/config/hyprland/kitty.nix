/**
* terminal
*/
{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  programs.kitty = {
    enable = true;
    package = pkgs-hyprland.kitty;
  };

  wayland.windowManager.hyprland.settings = {
    "$terminal" = "kitty";

    bind = [
      "$mainMod, T, exec, $terminal"
    ];
  };
}
