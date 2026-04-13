{ mkHyprlandModule, ... }:
{ lib, config, ... }:
let
  inherit (cfg.binds) mods;
  cfg = config.mixins.desktopEnvironment.hyprland;
  bin.browser = lib.getExe config.programs.librewolf.finalPackage;
in
mkHyprlandModule {
  wayland.windowManager.hyprland.settings.bind = [ "${mods.main}, B, exec, ${bin.browser}" ];
}
