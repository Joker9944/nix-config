{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  osConfig,
  ...
}:
{
  xdg.autostart.entries = [ "${osConfig.programs.steam.package}/share/applications/steam.desktop" ];

  home.packages = with pkgs; [
    prismlauncher
  ];

  programs = {
    _1password.gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9R2V8FqyXifBoVO3OndfpRrqxdwK1H/3qlm645l7rg";

    lutris = {
      enable = true;
      extraPackages = with pkgs; [
        mangohud
        winetricks
        gamemode
        umu-launcher
      ];
      protonPackages = [ pkgs-unstable.proton-ge-bin ];
      steamPackage = osConfig.programs.steam.package;
    };
  };

  gnome-settings = lib.mkIf config.desktopEnvironment.gnome.enable {
    peripherals.touchpad.enable = false;
  };

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1, 1920x1080@60.00Hz, 0x0, 1"
      "DP-2, 2560x1440@143.97Hz, 1920x0, 1"
      "DP-3, 1920x1080@60.00Hz, 4480x0, 1"
    ];

    workspace = [
      "1, monitor:DP-2, default:true"
      "5, monitor:DP-1, default:true"
      "6, monitor:DP-3, default:true"
      "name:gaming, monitor:DP-2"
    ];
  };

  programs.hyprlock.settings.input-field.monitor = "DP-2";
}
