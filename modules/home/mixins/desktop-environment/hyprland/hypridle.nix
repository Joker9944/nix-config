{ mkHyprlandModule, flake, ... }:
{
  lib,
  config,
  osConfig,
  pkgs-unstable,
  ...
}:
mkHyprlandModule {
  services.hypridle = {
    enable = true;
    package = pkgs-unstable.hypridle;

    settings = {
      general = {
        lock_cmd = "hyprlock";
        unlock_cmd = "pkill --exact hyprlock";
        before_sleep_cmd = "loginctl lock-session";
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
          on-timeout =
            if osConfig.mixins.hardware.battery.enable then
              "systemctl suspend-then-hibernate"
            else
              "systemctl suspend";
        }
      ];
    };
  };

  wayland.windowManager.hyprland.settings.bind =
    let
      inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
      inherit (flake.lib.hyprland) mkLuaCall;
      inherit (lib.generators) mkLuaInline;
    in
    [
      (mkLuaCall [
        "${mods.main} + ESCAPE"
        (mkLuaInline "hl.dsp.exec_cmd(\"loginctl lock-session\")")
        { description = "lock the session"; }
      ])
    ];
}
