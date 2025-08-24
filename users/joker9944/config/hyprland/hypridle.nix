/**
  * idle management daemon
*/
{
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
    pkill = "${pkgs.procps}/bin/pkill";
    hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
    hyprctl = "${osConfig.programs.hyprland.package}/bin/hyprctl";
    loginctl = "${pkgs.systemd}/bin/loginctl";
    systemctl = "${pkgs.systemd}/bin/systemctl";
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
