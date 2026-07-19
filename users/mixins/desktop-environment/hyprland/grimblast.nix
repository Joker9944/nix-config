{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-unstable,
  custom,
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
      inherit (custom.lib) mkLuaCall;
      inherit (lib.generators) mkLuaInline;
    in
    [
      (mkLuaCall [
        "PRINT"
        (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave area\")") # cSpell:ignore copysave
      ])
      (mkLuaCall [
        "${mods.main} + PRINT"
        (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave active\")")
      ])
      (mkLuaCall [
        "${mods.utility} + PRINT"
        (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave output\")")
      ])
    ];
}
