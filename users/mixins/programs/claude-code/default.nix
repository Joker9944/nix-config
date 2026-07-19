{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  options.mixins.programs.claude-code =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "claude-code config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.claude-code;
    in
    lib.mkIf cfg.enable {
      programs.claude-code = {
        enable = true;

        context = ./files/CLAUDE.md;

        plugins = [
          "${inputs.claude-plugins-official}/plugins/skill-creator"
          "${inputs.claude-plugins-official}/plugins/code-review"
          "${inputs.claude-okf-skills}"
        ];

        lspServers.nix = {
          command = lib.getExe pkgs.nil;
          extensionToLanguage.".nix" = "nix";
        };
      };
    };
}
