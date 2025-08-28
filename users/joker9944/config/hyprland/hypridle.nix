/**
  * idle management daemon
*/
{
  lib,
  config,
  osConfig,
  pkgs,
  pkgs-hyprland,
  utility,
  ...
}:
let
  inherit (config.windowManager.hyprland.custom.binds) mods;
  bin = {
    pkill = lib.getExe' pkgs.procps "pkill";
    hyprlock = lib.getExe config.programs.hyprlock.package;
    hyprctl = lib.getExe' osConfig.programs.hyprland.package "hyprctl";
    loginctl = lib.getExe' pkgs.systemd "loginctl";
    systemctl = lib.getExe' pkgs.systemd "systemctl";
  };
in
utility.custom.mkHyprlandModule config {
  services.hypridle = {
    enable = true;
    package = pkgs-hyprland.hypridle;

    settings = {
      general = {
        lock_cmd = bin.hyprlock;
        unlock_cmd = "${bin.pkill} --exact hyprlock";
        after_sleep_cmd = "${bin.hyprctl} dispatch dpms on";
      };

      listener = [
        {
          timeout = 10 * 60;
          on-timeout = "${bin.loginctl} lock-session";
        }
        {
          timeout = 15 * 60;
          on-timeout = "${bin.hyprctl} dispatch dpms off";
          on-resume = "${bin.hyprctl} dispatch dpms on";
        }
        {
          timeout = 30 * 60;
          on-timeout = "${bin.systemctl} suspend";
        }
      ];
    };
  };

  wayland.windowManager.hyprland.settings.bind = [
    "${mods.main}, ESCAPE, exec, ${bin.loginctl} lock-session"
    "${mods.main}, L, exec, ${bin.loginctl} lock-session"
  ];
}
