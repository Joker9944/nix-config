{ lib, config, ... }:
{
  options.mixins.programs.intelli-shell =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "intelli-shell config mixin";
    };

  config.programs.intelli-shell =
    let
      cfg = config.mixins.programs.intelli-shell;
    in
    lib.mkIf cfg.enable {
      enable = true;

      settings = {
        check_updates = false;
      };
    };
}
