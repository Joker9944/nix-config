{ mkMixinModule, ... }:
{ osConfig, ... }:
mkMixinModule "maintenance" {
  nix = { inherit (osConfig.nix) gc; };

  # Enable automatic upgrades
  services = {
    home-manager.autoUpgrade = {
      inherit (osConfig.system.autoUpgrade)
        enable
        persistent
        dates
        flake
        ;

      notify.enable = true;
    };

    tidy = {
      cleanup.enable = true;

      emptyTrash = {
        enable = true;

        maxSizeMb = 20 * 1024;
        dates = "weekly";
      };
    };
  };
}
