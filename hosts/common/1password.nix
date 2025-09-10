{
  lib,
  config,
  ...
}:
{
  custom.nixpkgsCompat.allowUnfreePackages = [
    "1password"
    "1password-cli"
  ];

  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;

      polkitPolicyOwners = lib.attrsets.attrNames config.users.users;
    };
  };
}
