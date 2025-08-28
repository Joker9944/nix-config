{
  lib,
  config,
  osConfig,
  pkgs-hyprland,
  utility,
  ...
}:
let
  inherit (config.windowManager.hyprland.custom.binds) mods;
  pkg.playerctl = pkgs-hyprland.playerctl;
  bin = {
    wpctl = lib.getExe' osConfig.services.pipewire.wireplumber.package "wpctl";
    playerctl = lib.getExe pkg.playerctl;
  };
in
utility.custom.mkHyprlandModule config {
  home.packages = [ pkg.playerctl ]; # media applications control utility

  wayland.windowManager.hyprland.settings = {
    bind = [
      # default binds
      "${mods.main}, C, killactive,"
      "${mods.main}, M, exit,"
      "${mods.main}, V, togglefloating,"
      "${mods.main}, P, pseudo," # dwindle
      "${mods.main}, J, togglesplit," # dwindle

      # move focus
      "${mods.main}, left, movefocus, l"
      "${mods.main}, right, movefocus, r"
      "${mods.main}, up, movefocus, u"
      "${mods.main}, down, movefocus, d"

      # Example special workspace (scratchpad)
      "${mods.main}, S, togglespecialworkspace, magic"
      "${mods.workspace}, S, movetoworkspace, special:magic"
    ]
    ++ (lib.lists.flatten (
      lib.lists.genList (
        index:
        let
          key = toString (utility.math.mod (index + 1) 10);
          workspace = toString (index + 1);
        in
        [
          # switch workspace
          "${mods.main}, ${key}, workspace, ${workspace}"
          # move to workspace
          "${mods.workspace}, ${key}, movetoworkspace, ${workspace}"
        ]
      ) 10
    ));

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "${mods.main}, mouse:272, movewindow"
      "${mods.main}, mouse:273, resizewindow"
    ];

    bindel = [
      # Laptop multimedia keys for volume and LCD brightness
      ", XF86AudioRaiseVolume, exec, ${bin.wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, ${bin.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, ${bin.wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle" # TODO does this make sense to repeat?
      ", XF86AudioMicMute, exec, ${bin.wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle" # TODO does this make sense to repeat?
      ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+" # TODO brightnessctl missing
      ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-" # TODO brightnessctl missing
    ];

    bindl = [
      # Laptop multimedia keys for media control
      ", XF86AudioNext, exec, ${bin.playerctl} next"
      ", XF86AudioPause, exec, ${bin.playerctl} play-pause"
      ", XF86AudioPlay, exec, ${bin.playerctl} play-pause"
      ", XF86AudioPrev, exec, ${bin.playerctl} previous"
    ];
  };
}
