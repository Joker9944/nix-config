{
  lib,
  config,
  pkgs,
  pkgs-hyprland,
  custom,
  ...
}@args:
custom.lib.mkHyprlandModule config {
  options.windowManager.hyprland.custom.waybar = with lib; {
    gpu = mkEnableOption "gpu metrics";
    battery = mkEnableOption "battery metrics";
    stylus = mkEnableOption "stylus metrics";
  };

  config = {
    home.packages = [
      pkgs.nerd-fonts.symbols-only
    ];

    programs.waybar = {
      package = pkgs-hyprland.waybar;

      systemd.enable = true;

      settings = import ./settings.main.nix args;
      style = import ./style.css.nix args;
    };

    wayland.windowManager.hyprland.settings = {
      decoration.layerrule = [
        "blur, waybar"
        "xray 1, waybar"
      ];
    };
  };
}
