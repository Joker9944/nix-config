{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.programs.intelli-shell =
    let
      inherit (lib) mkOption types;
    in
    {
      commands = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              alias = mkOption { type = types.str; };
              command = mkOption { type = types.str; };
              description = mkOption { type = types.str; };
            };
          }
        );
        default = [ ];
      };
    };

  config.home.activation =
    let
      cfg = config.programs.intelli-shell;
    in
    lib.mkIf (cfg.enable && cfg.commands != [ ]) {
      # cSpell:words Intelli
      importIntelliShellCommands =
        let
          bin.intelli-shell = lib.getExe config.programs.intelli-shell.package;
          commands = lib.pipe cfg.commands [
            (lib.map (command: ''
              # [alias:${command.alias}] ${command.description}
              ${command.command}
            ''))
            lib.concatLines
            (pkgs.writeText "commands.sh")
          ];
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${bin.intelli-shell} import --file ${commands}
        '';
    };
}
