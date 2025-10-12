{
  lib,
  config,
  utility,
  ...
}:
let
  inherit (config.windowManager.hyprland.custom.binds) mods;
  specialWorkspaces = {
    discord = "discord";
    spotify = "spotify";
    telegram = "telegram";
  };
  bin = {
    discord = lib.getExe config.programs.discord.package;
    spotify = lib.getExe config.programs.spotify.package;
    telegram = lib.getExe config.programs.telegram.package;
  };
in
utility.custom.mkHyprlandModule config {
  # TODO split these app into their own modules
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${bin.telegram}"
    ];

    # cSpell:ignore wrappe
    bind = [
      "${mods.app}, D, togglespecialworkspace, ${specialWorkspaces.discord}"
      "${mods.app}, S, togglespecialworkspace, ${specialWorkspaces.spotify}"
      "${mods.app}, T, togglespecialworkspace, ${specialWorkspaces.telegram}"
    ];

    workspace = [
      "special:${specialWorkspaces.discord}, on-created-empty:${bin.discord}"
      "special:${specialWorkspaces.spotify}, on-created-empty:${bin.spotify}"
      "special:${specialWorkspaces.telegram}, on-created-empty:${bin.telegram}"
    ];

    windowrule = [
      "workspace special:${specialWorkspaces.spotify}, class:Spotify"
      "workspace special:${specialWorkspaces.telegram} silent, class:org.telegram.desktop"
      "float, content photo, class:org.telegram.desktop, title:Media viewer"
      "workspace special:${specialWorkspaces.discord}, class:vesktop"
    ];
  };
}
