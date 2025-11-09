{ lib, config, ... }:
{
  options.mixins.programs.wxmaxima =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "wxmaxima config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.wxmaxima;
    in
    lib.mkIf cfg.enable {
      programs = {
        wxmaxima.enable = true;

        yazi.settings.open.prepend_rules = [
          {
            name = "*.wxmx"; # cSpell:ignore wxmx
            use = [
              "open"
              "reveal"
            ];
          }
        ];
      };
    };
}
