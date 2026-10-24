{ mkMixinModule, ... }:
{ lib, osConfig, ... }:
mkMixinModule "maintenance" {
  # A submodule-typed definition is forced even while the mixin is disabled, and
  # osConfig is null outside a NixOS pairing (nix-on-droid).
  nix = lib.optionalAttrs (osConfig != null) { inherit (osConfig.nix) gc; };

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
