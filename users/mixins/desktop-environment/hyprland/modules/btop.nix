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
      in
      [
        "CTRL ALT, DELETE, exec, ${command}"
        "CTRL SHIFT, ESCAPE, exec, ${command}"
      ];

    windowrule = cfg.terminal.mkWindowRules {
      id = "btop";
    };
  };
}
