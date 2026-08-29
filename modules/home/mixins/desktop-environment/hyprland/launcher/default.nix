{ mkDefaultHyprlandModule, flake, ... }:
{
  lib,
  config,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland.launcher =
    let
      inherit (lib) mkOption types literalExpression;
    in
    {
      toggleCommand = mkOption {
        type = types.str;
        example = "vicinae toggle";
        description = ''
          Command to toggle the launcher.
        '';
      };

      mkDmenuCommand = mkOption {
        type = types.functionTo types.str;
        example = literalExpression ''
          {
            location ? null,
            search ? true,
            width ? null,
            height ? null,
            x ? null,
            y ? null,
            extraArgs ? [ ],
            ...
          }:
          lib.pipe
            [
              "wofi --dmenu"
              (lib.optional (location != null) "--location ''${location}")
              (lib.optional (!search) "--define hide_search=true")
              (lib.optional (width != null) "--width ''${toString width}")
              (lib.optional (height != null) "--height ''${toString height}")
              (lib.optional (x != null) "--xoffset ''${toString x}")
              (lib.optional (y != null) "--yoffset ''${toString y}")
              extraArgs
            ]
            [
              lib.flatten
              (lib.concatStringsSep " ")
            ]
        '';
        description = ''
          Function to generate a dmenu command.
        '';
      };
    };

  config = {
    assertions = [
      {
        assertion =
          lib.count (l: l.enable or false) (lib.filter lib.isAttrs (lib.attrValues cfg.launcher)) <= 1;
        message = "hyprland: enable at most one launcher, got ${
          toString (lib.attrNames (lib.filterAttrs (_: l: l.enable) cfg.launcher))
        }";
      }
    ];

    mixins.desktopEnvironment.hyprland.launcher.vicinae.enable = true;

    wayland.windowManager.hyprland.settings =
      let
        inherit (cfg.binds) mods;
        inherit (flake.lib.hyprland) mkLuaCall;
        inherit (lib.generators) mkLuaInline;
      in
      {
        bind = [
          (mkLuaCall [
            "${mods.main} + R"
            (mkLuaInline "hl.dsp.exec_cmd(\"${cfg.launcher.toggleCommand}\")")
          ])
          (mkLuaCall [
            "${mods.main} + ${mods.main}_L"
            (mkLuaInline "hl.dsp.exec_cmd(\"${cfg.launcher.toggleCommand}\")")
            { release = true; }
          ])
        ];
      };
  };
}
