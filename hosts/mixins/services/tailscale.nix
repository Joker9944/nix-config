{ lib, config, ... }:
{
  options.mixins.services.tailscale =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "tailscale config mixin";
    };

  config.services.tailscale.enable = config.mixins.services.tailscale.enable;
}
