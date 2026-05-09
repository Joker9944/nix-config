{ mkHyprlandModule, ... }:
{ config, pkgs-hyprland, ... }:
let
  inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
in
mkHyprlandModule {
  home.shellAliases.screenshot = "grimblast";

  programs.grimblast = {
    enable = true;
    package = pkgs-hyprland.grimblast;
  };

  wayland.windowManager.hyprland.settings.bind = [
    ", PRINT, exec, grimblast --notify --freeze copysave area" # cSpell:ignore copysave
    "${mods.main}, PRINT, exec, grimblast --notify --freeze copysave active"
    "${mods.utility}, PRINT, exec, grimblast --notify --freeze copysave output"
  ];
}
