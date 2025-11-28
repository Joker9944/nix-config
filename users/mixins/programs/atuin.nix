{ lib, config, ... }:
{
  options.mixins.programs.atuin =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "atuin config mixin";
    };

  config.programs.atuin =
    let
      cfg = config.mixins.programs.atuin;
    in
    lib.mkIf cfg.enable {
      enable = true;
    };
}
