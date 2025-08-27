{
  config,
  pkgs,
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
    pgrep = "${pkgs.procps}/bin/pgrep";
    discord = "${config.programs.discord.package}/bin/discord";
    spotify = "${config.programs.spotify.package}/bin/spotify";
    telegram = "${config.programs.telegram.package}/bin/telegram-desktop";
  };
in
utility.custom.mkHyprlandModule config {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${bin.telegram}"
    ];

    # cSpell:ignore wrappe
    bind = [
      "${mods.app}, D, exec, ${bin.pgrep} -x \".Discord-wrappe\" > /dev/null && hyprctl dispatch togglespecialworkspace ${specialWorkspaces.discord} || ${bin.discord}"
      "${mods.app}, S, exec, ${bin.pgrep} -x \".spotify-wrappe\" > /dev/null && hyprctl dispatch togglespecialworkspace ${specialWorkspaces.spotify} || ${bin.spotify}"
      "${mods.app}, T, togglespecialworkspace, ${specialWorkspaces.telegram}"
    ];

    windowrule = [
      "workspace special:${specialWorkspaces.spotify}, class:Spotify"
      "workspace special:${specialWorkspaces.telegram} silent, class:org.telegram.desktop"
      "float, class:org.telegram.desktop, title:Media viewer"
      "workspace special:${specialWorkspaces.discord}, class:discord"
    ];
  };
}
