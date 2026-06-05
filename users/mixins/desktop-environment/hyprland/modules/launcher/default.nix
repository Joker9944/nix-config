{ mkDefaultHyprlandModule, ... }:
{ lib, config, ... }:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland.launcher =
    let
      inherit (lib) mkOption types literalExpression;
    in
    {
      type = mkOption {
        type = types.str;
        description = ''
          Which launcher to use.
        '';
      };

      processName = mkOption {
        type = types.str;
        example = ".wofi-wrapped";
        description = ''
          The process name as reported by `ps -e`.
        '';
      };

      mkDrunCommand = mkOption {
        type = types.functionTo types.str;
        example = literalExpression ''
          { ... }: "''${bin.wofi}"
        '';
        description = ''
          Function to generate a drun command.
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
    mixins.desktopEnvironment.hyprland.launcher.type = "rofi";

    wayland.windowManager.hyprland.settings =
      let
        inherit (cfg.binds) mods;
        inherit (lib.generators) mkLuaInline;

        trimmedProcessName = lib.substring 0 15 cfg.launcher.processName; # maximum process name length is 15 characters
        drunCommand = cfg.launcher.mkDrunCommand {
          icons = true;
        };

        command = "pkill --exact \\\"${trimmedProcessName}\\\" || ${drunCommand}";
      in
      {
        bind = [
          {
            _args = [
              "${mods.main} + R"
              (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
            ];
          }
          {
            _args = [
              "${mods.main} + ${mods.main}_L"
              (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
              { release = true; }
            ];
          }
        ];
      };
  };
}
