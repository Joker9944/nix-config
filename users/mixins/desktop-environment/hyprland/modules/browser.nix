{ mkHyprlandModule, ... }:
{ lib, config, ... }:
let
  inherit (cfg.binds) mods;
  inherit (lib.generators) mkLuaInline;
  cfg = config.mixins.desktopEnvironment.hyprland;
  bin.browser = lib.getExe config.programs.librewolf.finalPackage;
in
mkHyprlandModule {
  wayland.windowManager.hyprland.settings.bind = [
    {
      _args = [
        "${mods.main} + B"
        (mkLuaInline "hl.dsp.exec_cmd(\"${bin.browser}\")")
      ];
    }
  ];
}
