/**
  * status bar
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
  cfg = config.windowManager.hyprland.custom;
in
utility.custom.mkHyprlandModule config {
  home.packages = [
    pkgs.nerd-fonts.symbols-only
    pkgs.audiomenu
  ];

  programs.waybar = {
    enable = true;
    package = pkgs-hyprland.waybar;

    systemd.enable = true;

    settings = import ./settings.main.nix { inherit osConfig cfg pkgs; };
    style = import ./style.css.nix { inherit cfg; };
  };

  wayland.windowManager.hyprland.settings = {
    decoration.layerrule = [
      "blur, waybar"
      "xray 1, waybar"
    ];
  };
}
