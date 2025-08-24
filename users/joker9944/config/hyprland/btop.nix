{
  lib,
  config,
  osConfig,
  pkgs-hyprland,
  utility,
  ...
}:
let
  inherit (cfg.binds) mods;
  cfg = config.windowManager.hyprland.custom;
  bin.btop = "${config.programs.btop.package}/bin/btop";
in
utility.custom.mkHyprlandModule config {
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
      [ "${mods.main}, B, exec, ${command}" ];

    windowrule = cfg.terminal.mkWindowRules {
      id = "btop";
    };
  };
}
