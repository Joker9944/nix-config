{
  lib,
  pkgs-unstable,
  config,
  utility,
  ...
}:
let
  cfg = config.custom.command-collection;
in
{
  options.custom.command-collection =
    let
      inherit (lib) mkEnableOption mkOption types;

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

      leafModule = types.submodule (_: {
        options = {
          help = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "Command to create a users.";
            description = ''
              Helper text that should be displayed for this leaf.
            '';
          };

          args = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };

          switches = mkOption {
            type = types.listOf parameterModule;
            default = [ ];
            description = ''
              Switches of this command.
            '';
          };

          code = mkOption {
            type = types.lines;
            example = "env";
            description = ''
              Python code to be executed.
            '';
          };
        };
      });

      branchModuleOptions = branchesType: {
        help = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "Commands to manage users.";
          description = ''
            Helper text that should be displayed on this branch.
          '';
        };

        showHelpByDefault = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Should the branch help text be shown if no leaf commands are supplied.
          '';
        };

        defaultLeaf = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            The leaf which should be executed by default.
          '';
        };

        callback = mkOption {
          type = types.nullOr leafModule;
          default = null;
        };

        branches = mkOption {
          type = types.attrsOf branchesType;
          default = { };
          description = ''
            List of branches.
          '';
        };

        leafs = mkOption {
          type = types.attrsOf leafModule;
          default = { };
          description = ''
            List of leaf commands.
          '';
        };
      };

      branchModule = lib.fix (
        self:
        types.submodule (_: {
          options = branchModuleOptions self;
        })
      );
    in
    (branchModuleOptions branchModule)
    // {
      enable = mkEnableOption "helper";

      name = mkOption {
        type = types.str;
        default = "command-collection";
        description = ''
          The top level command.
        '';
      };

      aliases = mkOption {
        type = types.listOf types.str;
        default = [ "cch" ];
        description = ''
          Shell aliases which should be set for `command-collection`.
        '';
      };
    };

  config =
    let
      cliPackage =
        let
          rootTyperName = "root";

          imports = ''
            import typer
            from typing_extensions import Annotated
            import subprocess
            from pathlib import Path
          '';

          prefix = imports;

          suffix = ''
            if __name__ == "__main__":
              ${rootTyperName}()
          '';

          # helper
          mkHelpParameter = attrset: lib.optional (attrset.help != null) "help=\"${attrset.help}\"";

          mkArguments = lib.concatStringsSep ", ";

          mkParameters =
            switches:
            lib.pipe switches [
              (lib.map (switch: "${switch.name}: ${switch.type}"))
              (lib.concatStringsSep ", ")
            ];

          mkDefaultLeafCallback =
            typer: leafName: leaf:
            let
              leafSwitchesWithoutContext = lib.filter (switch: switch.type != "typer.Context") leaf.switches;

              leafArguments = lib.pipe leaf.switches [
                (lib.map (switch: if switch.type != "typer.Context" then switch else { name = "ctx"; }))
                (lib.map (switch: switch.name))
                mkArguments
              ];
            in
            {
              args = [ "invoke_without_command=True" ];

              switches = [
                {
                  name = "ctx";
                  type = "typer.Context";
                }
              ]
              ++ leafSwitchesWithoutContext;

              code = ''
                if ctx.invoked_subcommand is None:
                  ${typer}_${leafName}(${leafArguments})
              '';
            };

          # branch
          mkBranch =
            super: branchName: branch:
            let
              typerName = if (super == null) then branchName else "${super}_${branchName}";
              _branch =
                branch
                // (lib.optionalAttrs (branch.defaultLeaf != null) {
                  callback = mkDefaultLeafCallback typerName branch.defaultLeaf branch.leafs.${branch.defaultLeaf};
                });
              typerArgs = mkArguments (
                (mkHelpParameter _branch) ++ (lib.optional (_branch.callback == null) "no_args_is_help=True")
              );
              typer = "${typerName} = typer.Typer(${typerArgs})";
              typerLink = "${super}.add_typer(${typerName}, name=\"${branchName}\")";
              callback = mkCallback typerName _branch.callback;
              leafs = lib.pipe _branch.leafs [
                (lib.mapAttrsToList (mkLeaf typerName))
                lib.concatLines
              ];
              childBranches = lib.pipe _branch.branches [
                (lib.mapAttrsToList (mkBranch typerName))
                lib.concatLines
              ];
            in
            lib.concatLines (
              [ typer ]
              ++ (lib.optional (super != null) typerLink)
              ++ (lib.optional (_branch.callback != null) callback)
              ++ (lib.optional (lib.length (lib.attrNames _branch.leafs) > 0) leafs)
              ++ (lib.optional (lib.length (lib.attrNames _branch.branches) > 0) childBranches)
            );

          mkCallback =
            typer: callback:
            let
              args = mkArguments callback.args;
            in
            ''
              @${typer}.callback(${args})
              def ${typer}_callback(${mkParameters callback.switches}):
              ${utility.custom.indentLines 2 callback.code}
            '';

          # leaf
          mkLeaf =
            typer: leafName: leaf:
            let
              args = mkArguments ([ "\"${leafName}\"" ] ++ leaf.args ++ (mkHelpParameter leaf));
            in
            ''
              @${typer}.command(${args})
              def ${typer}_${leafName}(${mkParameters leaf.switches}):
              ${utility.custom.indentLines 2 leaf.code}
            '';
        in
        pkgs-unstable.callPackage ./package.nix {
          pname = cfg.name;
          code = lib.concatLines [
            "#!/usr/bin/env python3"
            prefix
            (mkBranch null rootTyperName cfg)
            suffix
          ];
        };
    in
    lib.mkIf cfg.enable {
      programs.bash.initExtra = ''
        eval "$(${lib.getExe cliPackage} --show-completion bash)"
      '';

      home.packages = [ cliPackage ];
    };
}
