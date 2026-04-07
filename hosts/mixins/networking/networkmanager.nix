{ lib, config, ... }:
{
  options.mixins.networking.networkmanager =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "networkmanager config mixin";
    };

  config.networking.networkmanager.enable = lib.mkDefault config.mixins.networking.networkmanager.enable;
}
