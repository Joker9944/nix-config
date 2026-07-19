{ mkHyprlandModule, ... }:
{
  lib,
  config,
  osConfig,
  pkgs-unstable,
  custom,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
  id = "btop";
in
mkHyprlandModule {
  programs.btop = {
    enable = true;
    package =
      if lib.lists.elem "nvidia" osConfig.services.xserver.videoDrivers then
        pkgs-unstable.btop-cuda
      else
        pkgs-unstable.btop;
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        command = cfg.terminal.mkRunCommand {
          inherit id;
          command = "btop";
        };
        inherit (custom.lib) mkLuaCall;
        inherit (lib.generators) mkLuaInline;
      in
      [
        (mkLuaCall [
          "CTRL + ALT + DELETE"
          (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
        ])
        (mkLuaCall [
          "CTRL + ALT + ESCAPE"
          (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
        ])
      ];

    window_rule = cfg.terminal.mkWindowRules { inherit id; };
  };
}
