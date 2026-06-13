{ mkHyprlandModule, ... }:
{
  lib,
  config,
  osConfig,
  pkgs-hyprland,
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
        pkgs-hyprland.btop-cuda
      else
        pkgs-hyprland.btop;
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        inherit (custom.lib) mkLuaCall;
        terminalCommand = cfg.terminal.mkRunCommand {
          inherit id;
          command = "btop";
        };
        callPart = cfg.system.mkLuaRunPart { command = terminalCommand; };
      in
      [
        (mkLuaCall [
          "CTRL + ALT + DELETE"
          callPart
        ])
        (mkLuaCall [
          "CTRL + ALT + ESCAPE"
          callPart
        ])
      ];

    window_rule = cfg.terminal.mkWindowRules { inherit id; };
  };
}
