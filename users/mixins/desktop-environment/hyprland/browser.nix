{ mkHyprlandModule, ... }:
{
  lib,
  config,
  custom,
  ...
}:
let
  inherit (cfg.binds) mods;
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkHyprlandModule {
  wayland.windowManager.hyprland.settings.bind = [
    (custom.lib.mkLuaCall [
      "${mods.main} + B"
      (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"librewolf\")")
      { description = "open the default browser"; }
    ])
  ];
}
