{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-hyprland,
  ...
}:
let
  inherit (cfg.binds) mods;
  cfg = config.mixins.desktopEnvironment.hyprland;
  bin.yazi = lib.getExe config.programs.yazi.package;
in
mkHyprlandModule {
  home.packages = with pkgs-hyprland; [
    exiftool
    mediainfo
  ];

  programs.yazi = {
    enable = true;
    package = pkgs-hyprland.yazi;

    settings.opener.open = [
      {
        desc = "Open";
        run = "xdg-open \"$1\"";
        for = "linux";
      }
      {
        desc = "Open with";
        run = "clear; ${lib.getExe pkgs-hyprland.File-MimeInfo} --ask \"$1\"";
        block = true;
        for = "linux";
      }
    ];
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
