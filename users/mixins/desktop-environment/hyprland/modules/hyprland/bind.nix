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
      inherit (lib.generators) mkLuaInline;
    in
    [
      # default binds
      {
        _args = [
          "${mods.main} + C"
          (mkLuaInline "hl.dsp.window.close()")
        ];
      }
      {
        _args = [
          "${mods.main} + M"
          (mkLuaInline "hl.dsp.exec_cmd(\"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'\")")
        ];
      }
      {
        _args = [
          "${mods.main} + V"
          (mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
        ];
      }
      {
        _args = [
          "${mods.main} + P"
          (mkLuaInline "hl.dsp.window.pseudo()")
        ];
      }
      {
        _args = [
          "${mods.main} + J"
          (mkLuaInline "hl.dsp.layout(\"togglesplit\")")
        ];
      }

      # Move/resize windows with mainMod + LMB/RMB and dragging
      {
        _args = [
          "${mods.main} + mouse:272"
          (mkLuaInline "hl.dsp.window.drag()")
          { mouse = true; }
        ];
      }
      {
        _args = [
          "${mods.main} + mouse:273"
          (mkLuaInline "hl.dsp.window.resize()")
          { mouse = true; }
        ];
      }

      # multimedia keys for volume
      {
        _args = [
          "XF86AudioRaiseVolume"
          (mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+\")")
          {
            repeating = true;
            locked = true;
          }
        ];
      }
      {
        _args = [
          "XF86AudioLowerVolume"
          (mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-\")")
          {
            repeating = true;
            locked = true;
          }
        ];
      }
      {
        _args = [
          "XF86AudioMute"
          (mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioMicMute"
          (mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")")
          { locked = true; }
        ];
      }

      # multimedia keys for brightness
      {
        _args = [
          "XF86MonBrightnessUp"
          (mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%+\")")
          {
            repeating = true;
            locked = true;
          }
        ];
      }
      {
        _args = [
          "XF86MonBrightnessDown"
          (mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%-\")")
          {
            repeating = true;
            locked = true;
          }
        ];
      }

      # multimedia keys for media control
      {
        _args = [
          "XF86AudioNext"
          (mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")")
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioPrev"
          (mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")")
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioPause"
          (mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioPlay"
          (mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
          { locked = true; }
        ];
      }
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
          {
            _args = [
              "${mods.main} + ${key}"
              (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = ${workspace}})")
            ];
          }
          # move to workspace
          {
            _args = [
              "${mods.workspace} + ${key}"
              (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = ${workspace}})")
            ];
          }
        ]
      ) 10
    ))
    # move focus
    ++ (lib.map
      (direction: {
        _args = [
          "${mods.main} + ${direction}"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"${direction}\" })")
        ];
      })
      [
        "left"
        "right"
        "up"
        "down"
      ]
    );
}
