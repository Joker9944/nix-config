{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.home-manager =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "home-manager config mixin";
    };

  config.environment.systemPackages = lib.optional config.mixins.programs.home-manager.enable pkgs.home-manager;
}
