{
  inputs,
  lib,
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

        plugins = [
          "${inputs.claude-plugins-official}/plugins/skill-creator"
          "${inputs.claude-okf-skills}"
        ];
      };
    };
}
