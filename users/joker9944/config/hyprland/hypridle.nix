/**
* idle management daemon
*/
{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  services.hypridle = {
    enable = true;
    package = pkgs-hyprland.hypridle;

    settings = {
      general = {
        lock_cmd = "hyprlock";
        unlock_cmd = "pkill hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 10 * 60;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 15 * 60;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 30 * 60;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, ESCAPE, exec, loginctl lock-session"
    "$mainMod, L, exec, loginctl lock-session"
  ];
}
