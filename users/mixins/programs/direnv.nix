{ lib, config, ... }:
{
  options.mixins.programs.direnv =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "direnv config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.direnv;
    in
    lib.mkIf cfg.enable {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
}
