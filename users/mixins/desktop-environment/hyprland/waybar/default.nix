/**
  * status bar
*/
{
  lib,
  config,
  pkgs,
  pkgs-hyprland,
  utility,
  ...
}@args:
utility.custom.mkHyprlandModule config {
  options.windowManager.hyprland.custom.waybar = with lib; {
    gpu = mkEnableOption "gpu metrics";
    battery = mkEnableOption "battery metrics";
  };

  config = {
    home.packages = [
      pkgs.nerd-fonts.symbols-only
      pkgs.audiomenu
    ];

    programs.waybar = {
      enable = true;
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
