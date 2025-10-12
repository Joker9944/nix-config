{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.command-collection-helper;
in
{
  options.custom.command-collection-helper =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        ;
    in
    {
      enable = mkEnableOption "helper";

      aliases = mkOption {
        type = types.listOf types.str;
        default = [ "cch" ];
        description = ''
          Shell aliases which should be set for `command-collection-helper`.
        '';
      };

      rootHelp = mkOption {
        type = types.str;
        default = "Command collection cli completely managed in nix.";
        description = ''
          Helper text that should be displayed on the cli root.
        '';
      };

      commands =
        let
          parameterModule = types.submodule (_: {
            options = {
              name = mkOption {
                type = types.str;
                example = "username";
              };

              type = mkOption {
                type = types.str;
                example = "str";
              };
            };
          });

          commandLeafModule = types.submodule (_: {
            options = {
              name = mkOption {
                type = types.str;
                example = "create";
                description = ''
                  Name of the command.
                '';
              };

              switches = mkOption {
                type = types.listOf parameterModule;
                default = [ ];
                description = ''
                  Switches of this command.
                '';
              };

              command = mkOption {
                type = types.str;
                example = "env";
                description = ''
                  Shell command to be executed.
                '';
              };
            };
          });

          commandBranchModule = lib.fix (
            self:
            types.submodule (_: {
              options = {
                name = mkOption {
                  type = types.str;
                  example = "users";
                  description = ''
                    Name of the subcommand.
                  '';
                };

                help = mkOption {
                  type = types.str;
                  default = "Commands to manage users.";
                  description = ''
                    Helper text that should be displayed on this subcommand node.
                  '';
                };

                commands = mkOption {
                  type = types.listOf (
                    types.oneOf [
                      commandLeafModule
                      self.type
                    ]
                  );
                  default = [ ];
                  description = ''
                    List of subcommands or leaf commands.
                  '';
                };
              };
            })
          );
        in
        mkOption {
          type = types.listOf (
            types.oneOf [
              commandLeafModule
              commandBranchModule
            ]
          );
          default = [ ];
          description = ''
            List of subcommands or leaf commands.
          '';
        };
    };

  config = {
    programs.bash.shellAliases = lib.listToAttrs (
      map (alias: {
        name = alias;
        value = "command-collection-helper";
      }) cfg.aliases
    );

    # cSpell:ignore typer
    home.packages =
      let
        imports = ''
          import typer
          import subprocess
        '';
        prefix = ''
          root = typer.Typer(help="${cfg.rootHelp}")
        '';
        suffix = ''
          if __name__ == "__main__":
            root()
        '';
        branchBuilder = super: typer: leafCommands: ''
          ${typer.name} = typer.Typer()
          ${super}.add_typer(${typer.name})
        '';
      in
      [
        (pkgs.callPackage ./package.nix {
          code = lib.concatLines [
            imports
            prefix
            suffix
          ];
        })
      ];
  };
}
