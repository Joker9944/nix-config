{ lib, config, ... }:
{
  options.mixins.programs.anki =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "anki config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.anki;
    in
    lib.mkIf cfg.enable {
      programs.anki = {
        enable = true;
      };
    };
}
