{ lib, config, ... }:
{
  options.mixins.programs.starship =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "starship config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.starship;
    in
    lib.mkIf cfg.enable {
      programs.starship = {
        enable = true;
        presets = [ "nerd-font-symbols" ];
      };
    };
}
