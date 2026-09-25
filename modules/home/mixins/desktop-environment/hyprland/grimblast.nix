{ mkHyprlandModule, flake, ... }:
{
  lib,
  config,
  pkgs-unstable,
  ...
}:
mkHyprlandModule {
  home.shellAliases.screenshot = "grimblast";

  programs.grimblast = {
    enable = true;
    package = pkgs-unstable.grimblast;
  };

  wayland.windowManager.hyprland.settings.bind =
    let
      inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
      inherit (flake.lib.hyprland) mkLuaCall;
      inherit (lib.generators) mkLuaInline;
    in
    [
      (mkLuaCall [
        "PRINT"
        (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave area\")") # cSpell:ignore copysave
        { description = "screenshot a selected area"; }
      ])
      (mkLuaCall [
        "${mods.main} + PRINT"
        (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave active\")")
        { description = "screenshot the active window"; }
      ])
      (mkLuaCall [
        "${mods.variant} + PRINT"
        (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave output\")")
        { description = "screenshot the whole output"; }
      ])
    ];
}
