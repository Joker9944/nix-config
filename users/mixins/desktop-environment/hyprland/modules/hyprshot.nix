{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-hyprland,
  ...
}:
let
  inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
  bin.hyprshot = lib.getExe config.programs.hyprshot.package;
in
mkHyprlandModule {
  home.shellAliases.screenshot = "hyprshot";

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
