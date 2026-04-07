{ lib, config, ... }:
{
  options.mixins.virtualisation.docker =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "docker config mixin";
    };

  config.virtualisation.docker.enable = lib.mkDefault config.mixins.virtualisation.docker.enable;
}
