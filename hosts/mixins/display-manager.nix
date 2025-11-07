{ lib, config, ... }:
{
  options.mixins.displayManager =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "displayManager config mixin";
    };

  config.services =
    let
      cfg = config.mixins.displayManager;
    in
    lib.mkIf cfg.enable {
      displayManager = {
        ly = {
          enable = lib.mkDefault true;
        };
      };
    };
}
