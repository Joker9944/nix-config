{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-hyprland,
  custom,
  ...
}:
mkHyprlandModule {
  home.packages = with pkgs-hyprland; [
    brightnessctl
    playerctl
    hyprshutdown
  ];

  wayland.windowManager.hyprland.settings.bind =
    let
      inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
      inherit (custom.lib) mkLuaCall;
      inherit (lib.generators) mkLuaInline;
    in
    [
      # default binds
      (mkLuaCall [
        "${mods.main} + C"
        (mkLuaInline "hl.dsp.window.close()")
        { description = "close active window"; }
      ])
      (mkLuaCall [
        "${mods.main} + M"
        (mkLuaInline "hl.dsp.exec_cmd(\"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'\")")
        { description = "exit current hyprland session"; }
      ])
      (mkLuaCall [
        "${mods.main} + V"
        (mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
        { description = "toggle floating mode of active window"; }
      ])
      (mkLuaCall [
        "${mods.main} + P"
        (mkLuaInline "hl.dsp.window.pseudo()")
        { description = "toggle pseudo mode of active window"; }
      ])
      (mkLuaCall [
        "${mods.main} + J"
        (mkLuaInline "hl.dsp.layout(\"togglesplit\")")
        { description = "toggle the split view of active window"; }
      ])

      # window control
      (mkLuaCall [
        "${mods.main} + mouse:272"
        (mkLuaInline "hl.dsp.window.drag()")
        {
          description = "drag active window";
          mouse = true;
        }
      ])
      (mkLuaCall [
        "${mods.main} + mouse:273"
        (mkLuaInline "hl.dsp.window.resize()")
        {
          description = "resize active window";
          mouse = true;
        }
      ])

      # multimedia keys for volume
      (mkLuaCall [
        "XF86AudioRaiseVolume"
        (mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+\")")
        {
          description = "raise volume of active pw sink by 5%";
          repeating = true;
          locked = true;
        }
      ])
      (mkLuaCall [
        "XF86AudioLowerVolume"
        (mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-\")")
        {
          description = "lower volume of active pw sink by 5%";
          repeating = true;
          locked = true;
        }
      ])
      (mkLuaCall [
        "XF86AudioMute"
        (mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
        {
          description = "toggle mute of active pw sink";
          locked = true;
        }
      ])
      (mkLuaCall [
        "XF86AudioMicMute"
        (mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")")
        {
          description = "toggle mute of active pw source";
          locked = true;
        }
      ])

      # multimedia keys for brightness
      (mkLuaCall [
        "XF86MonBrightnessUp"
        (mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%+\")")
        {
          description = "raise screen brightness by 5%";
          repeating = true;
          locked = true;
        }
      ])
      (mkLuaCall [
        "XF86MonBrightnessDown"
        (mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%-\")")
        {
          description = "lower screen brightness by 5%";
          repeating = true;
          locked = true;
        }
      ])

      # multimedia keys for media control
      (mkLuaCall [
        "XF86AudioNext"
        (mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")")
        {
          description = "next for current mpris player";
          locked = true;
        }
      ])
      (mkLuaCall [
        "XF86AudioPrev"
        (mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")")
        {
          description = "previous for current mpris player";
          locked = true;
        }
      ])
      (mkLuaCall [
        "XF86AudioPause"
        (mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
        {
          description = "toggle pause for current mpris player";
          locked = true;
        }
      ])
      (mkLuaCall [
        "XF86AudioPlay"
        (mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
        {
          description = "toggle pause for current mpris player";
          locked = true;
        }
      ])
    ]
    # workspaces
    ++ (lib.lists.flatten (
      lib.lists.genList (
        index:
        let
          key = toString (custom.math.mod (index + 1) 10);
          workspace = toString (index + 1);
        in
        [
          # switch workspace
          (mkLuaCall [
            "${mods.main} + ${key}"
            (mkLuaInline "hl.dsp.focus({ workspace = ${workspace}})")
            { description = "focus workspace ${workspace}"; }
          ])
          # move to workspace
          (mkLuaCall [
            "${mods.workspace} + ${key}"
            (mkLuaInline "hl.dsp.window.move({ workspace = ${workspace}})")
            { description = "move active window to workspace ${workspace}"; }
          ])
        ]
      ) 10
    ))
    # move focus
    ++ (lib.map
      (
        direction:
        mkLuaCall [
          "${mods.main} + ${direction}"
          (mkLuaInline "hl.dsp.focus({ direction = \"${direction}\" })")
          { description = "focus window ${direction} of active window"; }
        ]
      )
      [
        "left"
        "right"
        "up"
        "down"
      ]
    );
}
