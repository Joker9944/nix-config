{ mkHyprlandModule, flake, ... }:
{
  lib,
  config,
  ...
}:
let
  inherit (cfg.binds) mods;
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkHyprlandModule {
  wayland.windowManager.hyprland.settings.bind =
    let
      command = cfg.mkAppEntryCommand { package = config.programs.librewolf.finalPackage; };
    in
    lib.mkIf config.programs.librewolf.enable [
      (flake.lib.hyprland.mkLuaCall [
        "${mods.main} + B"
        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
        { description = "open the default browser"; }
      ])
    ];
}
