{ lib, config, ... }:
{
  options.mixins.programs.isd =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "isd config mixin";
    };

  config.programs.isd =
    let
      cfg = config.mixins.programs.isd;
    in
    lib.mkIf cfg.enable {
      enable = true;
    };
}
