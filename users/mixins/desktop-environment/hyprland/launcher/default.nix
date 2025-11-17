{
  lib,
  config,
  pkgs,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  options.windowManager.hyprland.custom.launcher =
    let
      inherit (lib) mkOption types literalExpression;
    in
    {
      type = mkOption {
        type = types.enum [
          "wofi"
          "rofi"
        ];
        default = "wofi";
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

  config =
    let
      cfg = config.windowManager.hyprland.custom;
    in
    {
      services.dunst.settings.global.dmenu = cfg.launcher.mkDmenuCommand { };

      wayland.windowManager.hyprland.settings =
        let
          inherit (cfg.binds) mods;
          bin.pkill = lib.getExe' pkgs.procps "pkill";
          trimmedProcessName = lib.substring 0 15 cfg.launcher.processName; # maximum process name length is 15 characters
          command = "${bin.pkill} --exact \"${trimmedProcessName}\" || ${cfg.launcher.mkDrunCommand}";
        in
        {
          bindr = [
            "${mods.main}, SUPER_L, exec, ${command}"
          ];

          bind = [
            "${mods.main}, R, exec, ${command}"
          ];
        };
    };
}
