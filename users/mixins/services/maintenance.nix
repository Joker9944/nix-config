{
  lib,
  config,
  osConfig,
  ...
}:
{
  options.mixins.services.maintenance =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "maintenance config mixin";
    };

  config =
    let
      cfg = config.mixins.services.maintenance;
    in
    lib.mkIf cfg.enable {
      nix = { inherit (osConfig.nix) gc; };

      # Enable automatic upgrades
      services.home-manager.autoUpgrade = {
        inherit (osConfig.system.autoUpgrade)
          enable
          persistent
          dates
          flake
          ;

        notify.enable = true;
      };
    };
}
