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

    # WORKAROUND(nostalgic-lovelace) Has to be set since `home.stateVersion` is less than "26.05"
    shellWrapperName = "y";

    settings.opener.open = [
      {
        desc = "Open";
        run = "xdg-open %s1";
        for = "linux";
      }
      {
        desc = "Open with";
        run = "clear; ${lib.getExe pkgs-unstable.File-MimeInfo} --ask %s1";
        block = true;
        for = "linux";
      }
    ];
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        inherit (cfg.binds) mods;
        inherit (custom.lib.hyprland) mkLuaCall;
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
