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
    (cfg.lib.mkAppWorkspace {
      inherit id;
      class = id;
      launch = cfg.terminal.lib.mkRunCommand {
        inherit id;
        command = "btop";
      };
    })
    { window_rule = cfg.terminal.lib.mkWindowRules { inherit id; }; }
  ];
}
