{lib, ...}: {
  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;

      polkitPolicyOwners = (lib.attrsets.attrNames config.users.users);
    };
  };
}
