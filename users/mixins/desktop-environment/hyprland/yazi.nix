{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-unstable,
  custom,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
  id = "yazi";
in
mkHyprlandModule {
  home.packages = with pkgs-unstable; [
    exiftool
    mediainfo
  ];

  programs.yazi = {
    enable = true;
    package = pkgs-unstable.yazi;

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
        run = "clear; ${lib.getExe pkgs-unstable.File-MimeInfo} --ask \"$1\"";
        block = true;
        for = "linux";
      }
    ];
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        inherit (cfg.binds) mods;
        inherit (custom.lib) mkLuaCall;
        inherit (lib.generators) mkLuaInline;
        command = cfg.terminal.mkRunCommand {
          inherit id;
          command = "yazi";
        };
      in
      [
        (mkLuaCall [
          "${mods.main} + E"
          (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
        ])
      ];

    window_rule = cfg.terminal.mkWindowRules { inherit id; };
  };
}
