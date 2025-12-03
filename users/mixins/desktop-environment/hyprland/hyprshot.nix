/**
  * screenshot utility
*/
{
  lib,
  config,
  pkgs-hyprland,
  custom,
  ...
}:
let
  inherit (config.windowManager.hyprland.custom.binds) mods;
  bin.hyprshot = lib.getExe config.programs.hyprshot.package;
in
custom.lib.mkHyprlandModule config {
  programs.hyprshot = {
    enable = true;
    package = pkgs-hyprland.hyprshot;

    saveLocation = "$HOME/Pictures/Screenshots";
  };

  wayland.windowManager.hyprland.settings.bind = [
    ", PRINT, exec, ${bin.hyprshot} --mode region"
    "${mods.main}, PRINT, exec, ${bin.hyprshot} --mode active"
    "${mods.utility}, PRINT, exec, ${bin.hyprshot} --mode output"
  ];
}
