/**
* file explorer
*/
{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  programs.yazi = {
    enable = true;
    package = pkgs-hyprland.yazi;
  };

  wayland.windowManager.hyprland.settings = {
    "$fileManager" = "kitty --app-id=yazi yazi";

    bind = [
      "$mainMod, E, exec, $fileManager"
    ];
  };
}
