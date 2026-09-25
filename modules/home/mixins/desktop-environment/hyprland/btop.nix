{ mkHyprlandModule, ... }:
{
  lib,
  config,
  osConfig,
  pkgs-unstable,
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

  wayland.windowManager.hyprland.settings = lib.mkMerge [
    (cfg.mkAppWorkspace {
      inherit id;
      class = id;
      launch = cfg.terminal.mkRunCommand {
        inherit id;
        command = "btop";
      };
    })
    { window_rule = cfg.terminal.mkWindowRules { inherit id; }; }
  ];
}
