{ lib, config, ... }:
{
  options.mixins.programs.kitty =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "kitty config mixin";
    };

  config.programs.kitty =
    let
      cfg = config.mixins.programs.kitty;
    in
    lib.mkIf cfg.enable {
      enable = true;

      enableGitIntegration = true;
    };
}
