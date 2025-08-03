{
  lib,
  config,
  ...
}: {
  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;

      polkitPolicyOwners = lib.attrsets.attrNames config.users.users;
    };

    # Force install the 1Password extension
    firefox.policies.ExtensionSettings."{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
      installation_mode = "force_installed";
    };
  };
}
