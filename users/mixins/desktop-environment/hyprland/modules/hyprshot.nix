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
  programs = {
    hyprshot = {
      enable = true;
      package = pkgs-hyprland.hyprshot;

      saveLocation = "$HOME/Pictures/Screenshots";
    };

    bash.shellAliases.screenshot = "hyprshot";
  };

  wayland.windowManager.hyprland.settings.bind = [
    ", PRINT, exec, ${bin.hyprshot} --mode region"
    "${mods.main}, PRINT, exec, ${bin.hyprshot} --mode active"
    "${mods.utility}, PRINT, exec, ${bin.hyprshot} --mode output"
  ];
}
