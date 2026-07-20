{ mkMixinModule, ... }:
{ osConfig, ... }:
mkMixinModule "maintenance" {
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
}
