{
  lib,
  pkgs,
  config,
  osConfig,
  custom,
  ...
}:
{
  xdg.autostart.entries = [ "${osConfig.programs.steam.package}/share/applications/steam.desktop" ];

  home.packages = with pkgs; [
    prismlauncher
  ];

  mixins.programs.lutris.enable = true;

  programs = {
    _1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";

    # TODO disabled due to security issues with qtwebengine
    teamspeak.enable = false;

    librewolf.profiles = {
      "Work" = {
        id = 1;
        path = "work";
      };

      "Homework" = {
        id = 2;
        path = "homework";
      };
    };
  };

  gnome-settings = lib.mkIf config.mixins.desktopEnvironment.gnome.enable {
    peripherals.touchpad.enable = false;
  };

  # Hyprland
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "DP-1";
        mode = "1920x1080@60.00Hz";
        position = "0x0";
      }
      {
        output = "DP-2";
        mode = "2560x1440@143.97Hz";
        position = "1920x0";
      }
      {
        output = "DP-3";
        mode = "1920x1080@60.00Hz";
        position = "4480x0";
      }
    ];

    on = custom.lib.mkLuaCall [
      "hyprland.start"
      (lib.generators.mkLuaInline ''
        function()
          hl.exec_cmd("${lib.getExe pkgs.xrandr} --output DP-2 --primary")
        end
      '')
    ];

    workspace_rule = [
      {
        workspace = "1";
        monitor = "DP-2";
        default = true;
      }
      {
        workspace = "2";
        monitor = "DP-2";
      }
      {
        workspace = "3";
        monitor = "DP-2";
      }
      {
        workspace = "4";
        monitor = "DP-2";
      }
      {
        workspace = "5";
        monitor = "DP-1";
        default = true;
      }
      {
        workspace = "6";
        monitor = "DP-1";
      }
      {
        workspace = "7";
        monitor = "DP-1";
      }
      {
        workspace = "8";
        monitor = "DP-3";
        default = true;
      }
      {
        workspace = "9";
        monitor = "DP-3";
      }
      {
        workspace = "0";
        monitor = "DP-3";
      }
      {
        workspace = "name:gaming";
        monitor = "DP-2";
      }
    ];

    config.input = {
      sensitivity = 0.5;
      accel_profile = "flat";
    };
  };

  mixins.desktopEnvironment.hyprland.waybar.gpu = true;
  programs.yas.config.gpu = true;

  programs.hyprlock.settings.input-field.monitor = "DP-2";
}
