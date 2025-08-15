{
  lib,
  utility,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$workspaceMod" = "SHIFT";

    bindr = [
      "$mainMod, $mainMod + L, exec, pkill wofi || $menu" # TODO find a way to not ref wofi directly.
    ];

    bind =
      [
        # default binds
        "$mainMod, T, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo," # dwindle
        "$mainMod, J, togglesplit," #dwindle

        # move focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Example special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod $workspaceMod, S, movetoworkspace, special:magic"

        # Utilities
        "$mainMod CTRL, V, exec, $clipboard"
        "$mainMod, ESCAPE, exec, loginctl lock-session"
        "$mainMod, L, exec, loginctl lock-session"
      ]
      ++ (lib.lists.flatten (lib.lists.genList (index: let
          key = toString (utility.math.mod (index + 1) 10);
          workspace = toString (index + 1);
        in [
          # switch workspace
          "$mainMod, ${key}, workspace, ${workspace}"
          # move to workspace
          "$mainMod $workspaceMod, ${key}, movetoworkspace, ${workspace}"
        ])
        10));

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindel = [
      # Laptop multimedia keys for volume and LCD brightness
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" # TODO does this make sense to repeat?
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" # TODO does this make sense to repeat?
      ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    bindl = [
      # Laptop multimedia keys for media control
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
