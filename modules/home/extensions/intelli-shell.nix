{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.programs.intelli-shell =
    let
      inherit (lib) mkOption types literalExpression;
    in
    {
      defaultTag = mkOption {
        type = types.str;
        default = "managed";
        description = ''
          Tag to be added to all commands to indicate that they are managed through this module.
        '';
      };

      commands = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              command = mkOption {
                type = types.str;
                example = "sudo nixos-rebuild switch --flake {{~/Workspace/nix-config|github:joker9944/nix-config}}";
              };

              alias = mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "nix update";
              };

              description = mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "Update nix with flake";
              };

              tags = mkOption {
                type = types.listOf types.str;
                default = [ ];
                example = literalExpression "[ \"nix\" ]";
              };
            };
          }
        );
        default = [ ];
      };
    };

  config.home.activation =
    let
      cfg = config.programs.intelli-shell;

      mkCommand =
        command:
        let
          tags = [ cfg.defaultTag ] ++ command.tags;
          mkCommandHeader =
            lib.pipe
              [
                (lib.optional (command.alias != null) "[alias:${command.alias}]")
                (lib.optional (command.description != null) command.description)
                (lib.map (tag: "#${tag}") tags)
              ]
              [
                lib.flatten
                (lib.concatStringsSep " ")
                (parts: "# ${parts}\n")
              ];
        in
        mkCommandHeader + command.command;
    in
    lib.mkIf (cfg.enable && cfg.commands != [ ]) {
      # cSpell:words Intelli
      importIntelliShellCommands =
        let
          imports = lib.pipe cfg.commands [
            (lib.map mkCommand)
            lib.concatLines
            (pkgs.writeText "imports")
          ];
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${lib.getExe config.programs.intelli-shell.package} import --file ${imports}
        '';
    };
}
