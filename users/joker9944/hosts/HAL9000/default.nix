{
  lib,
  pkgs,
  pkgs-hyprland,
  config,
  osConfig,
  custom,
  ...
}:
let
  bin.xrandr = lib.getExe pkgs-hyprland.xorg.xrandr;
in
{
  imports = custom.lib.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  xdg.autostart.entries = [ "${osConfig.programs.steam.package}/share/applications/steam.desktop" ];

  home.packages = with pkgs; [
    prismlauncher
  ];

  mixins.programs.lutris.enable = true;

  programs = {
    _1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";

    # TODO disabled due to security issues with qtwebengine
    teamspeak.enable = false;
  };

  gnome-settings = lib.mkIf config.mixins.desktopEnvironment.gnome.enable {
    peripherals.touchpad.enable = false;
  };

  # Hyprland
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1, 1920x1080@60.00Hz, 0x0, 1"
      "DP-2, 2560x1440@143.97Hz, 1920x0, 1"
      "DP-3, 1920x1080@60.00Hz, 4480x0, 1"
    ];

    exec-once = [
      "${bin.xrandr} --output DP-2 --primary"
    ];

    workspace = [
      "1, monitor:DP-2, default:true"
      "2, monitor:DP-2, default:true"
      "3, monitor:DP-2, default:true"
      "4, monitor:DP-2, default:true"
      "5, monitor:DP-1, default:true"
      "6, monitor:DP-1, default:true"
      "7, monitor:DP-3, default:true"
      "8, monitor:DP-3, default:true"
      "name:gaming, monitor:DP-2"
    ];

    input = {
      sensitivity = 0.5;
      accel_profile = "flat";
    };
  };

  windowManager.hyprland.custom.waybar.gpu = true;

  programs.hyprlock.settings.input-field.monitor = "DP-2";
}
