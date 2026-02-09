{ lib, config, ... }:
{
  options.mixins.services.remmina =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "remmina config mixin";
    };

  config =
    let
      cfg = config.mixins.services.remmina;
    in
    lib.mkIf cfg.enable {
      services.remmina.enable = true;
    };
}
