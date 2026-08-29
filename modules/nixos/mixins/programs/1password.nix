{ mkMixinModule, ... }:
{ lib, config, ... }:
mkMixinModule "_1password" {
  custom.nixpkgsCompat.allowUnfreePackages = [
    "1password"
    "1password-cli"
  ];

  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;

      polkitPolicyOwners = lib.attrNames config.users.users;

      additionalAllowedBrowsers = [ "librewolf" ];
    };
  };
}
