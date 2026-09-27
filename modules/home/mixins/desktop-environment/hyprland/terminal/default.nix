{ mkDefaultHyprlandModule, ... }:
{
  lib,
  pkgs,
  ...
}:
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland.terminal =
    let
      inherit (lib)
        mkPackageOption
        mkOption
        types
        literalExpression
        ;
    in
    {
      package = mkPackageOption pkgs "terminal" {
        default = null;
      };

      lib = {
        mkRunCommand = mkOption {
          type = types.functionTo types.str;
          example = literalExpression ''
            {
              id,
              command,
              ...
            }:
            cfg.lib.mkAppCommand {
              name = id;
              elems = [
                "foot"
                "--app-id"
                id
                command
              ];
            }
          '';
          description = ''
            Function to generate a command to run a command in terminal.
          '';
        };

        mkWindowRules = mkOption {
          type = types.functionTo (types.listOf types.attrs);
          example = literalExpression ''
            { id, ... }:
            [
              {
                name = "terminal-''${id}";
                match.class = id;
                min_size = lib.generators.mkLuaInline "{ 720, 480 }";
              }
            ]
          '';
          description = ''
            Function to generate Hyprland window rules for terminal windows.
          '';
        };
      };
    };
}
