{ lib, config, ... }:
{
  options.mixins.programs.isd =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "isd config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.isd;
    in
    lib.mkIf cfg.enable {
      home.shellAliases.sc = "isd";

      programs.isd.enable = true;
    };
}
