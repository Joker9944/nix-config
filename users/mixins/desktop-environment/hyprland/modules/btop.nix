{ mkHyprlandModule, ... }:
{
  lib,
  config,
  osConfig,
  pkgs-hyprland,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
  bin.btop = lib.getExe config.programs.btop.package;
in
mkHyprlandModule {
  programs.btop = {
    enable = true;
    package =
      if lib.lists.elem "nvidia" osConfig.services.xserver.videoDrivers then
        pkgs-hyprland.btop-cuda
      else
        pkgs-hyprland.btop;
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        command = cfg.terminal.mkRunCommand {
          id = "btop";
          command = bin.btop;
        };
        inherit (lib.generators) mkLuaInline;
      in
      [
        {
          _args = [
            "CTRL + ALT + DELETE"
            (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
          ];
        }
        {
          _args = [
            "CTRL + ALT + ESCAPE"
            (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
          ];
        }
      ];

    window_rule = cfg.terminal.mkWindowRules {
      id = "btop";
    };
  };
}
