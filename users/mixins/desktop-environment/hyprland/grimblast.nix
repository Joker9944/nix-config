{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-hyprland,
  ...
}:
mkHyprlandModule {
  home.shellAliases.screenshot = "grimblast";

  programs.grimblast = {
    enable = true;
    package = pkgs-hyprland.grimblast;
  };

  wayland.windowManager.hyprland.settings.bind =
    let
      inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
      inherit (lib.generators) mkLuaInline;
    in
    [
      {
        _args = [
          "PRINT"
          (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave area\")") # cSpell:ignore copysave
        ];
      }
      {
        _args = [
          "${mods.main} + PRINT"
          (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave active\")")
        ];
      }
      {
        _args = [
          "${mods.utility} + PRINT"
          (mkLuaInline "hl.dsp.exec_cmd(\"grimblast --notify --freeze copysave output\")")
        ];
      }
    ];
}
