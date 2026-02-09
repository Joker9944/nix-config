{ lib, config, ... }:
{
  options.mixins.services.wayvnc =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "wayvnc config mixin";
    };

  config =
    let
      cfg = config.mixins.services.wayvnc;
    in
    lib.mkIf cfg.enable {
      services.wayvnc = {
        enable = true;
        settings = {
          address = "127.0.0.1";
          port = 5900;
        };
      };
    };
}
