/**
  * file explorer
*/
{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  inherit (cfg.binds) mods;
  cfg = config.windowManager.hyprland.custom;
  bin.yazi = lib.getExe config.programs.yazi.package;
in
utility.custom.mkHyprlandModule config {
  home.packages = with pkgs-hyprland; [
    exiftool
    mediainfo
  ];

  programs.yazi = {
    enable = true;
    package = pkgs-hyprland.yazi;
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        command = cfg.terminal.mkRunCommand {
          id = "yazi";
          command = bin.yazi;
        };
      in
      [ "${mods.main}, E, exec, ${command}" ];

    windowrule = cfg.terminal.mkWindowRules {
      id = "yazi";
    };
  };
}
