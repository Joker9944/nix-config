{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-hyprland,
  ...
}:
let
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

    # WORKAROUND Has to be set since `home.stateVersion` is less than "26.05"
    shellWrapperName = "y";

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
        inherit (cfg.binds) mods;
        inherit (lib.generators) mkLuaInline;
        command = cfg.terminal.mkRunCommand {
          id = "yazi";
          command = bin.yazi;
        };
      in
      [
        {
          _args = [
            "${mods.main} + E"
            (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
          ];
        }
      ];

    window_rule = cfg.terminal.mkWindowRules {
      id = "yazi";
    };
  };
}
