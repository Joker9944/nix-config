{
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  wayland.windowManager.hyprland.settings = {
    "$appMod" = "ALT";

    "$discordWorkspace" = "discord";
    "$spotifyWorkspace" = "spotify";
    "$telegramWorkspace" = "telegram";

    exec-once = [
      "telegram-desktop"
    ];

    bind = [
      "$mainMod $appMod, S, exec, pgrep -x \".spotify-wrappe\" > /dev/null && hyprctl dispatch togglespecialworkspace $spotifyWorkspace || spotify"
      "$mainMod $appMod, T, togglespecialworkspace, telegram"
      "$mainMod $appMod, D, exec, pgrep -x \".Discord-wrappe\" > /dev/null && hyprctl dispatch togglespecialworkspace $discordWorkspace || discord"
    ];

    windowrule = [
      "workspace special:$spotifyWorkspace, class:Spotify"
      "workspace special:$telegramWorkspace silent, class:org.telegram.desktop"
      "workspace special:$discordWorkspace, class:discord"
    ];
  };
}
