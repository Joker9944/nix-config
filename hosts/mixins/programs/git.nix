{ lib, config, ... }:
{
  options.mixins.programs.git =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "git config mixin";
    };

  config.programs.git.enable = lib.mkDefault config.mixins.programs.git.enable;
}
