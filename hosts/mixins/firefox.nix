{ lib, config, ... }:
{
  options.mixins.programs.firefox =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "Firefox config mixin";
    };

  config.programs.firefox =
    let
      cfg = config.mixins.programs.firefox;
    in
    lib.mkIf cfg.enable {
      enable = true;

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
      };
    };
}
