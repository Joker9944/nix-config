{ lib, config, ... }:
{
  options.mixins.programs._1password =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "1Password config mixin";
    };

  config =
    let
      cfg = config.mixins.programs._1password;
    in
    lib.mkIf cfg.enable {
      custom.nixpkgsCompat.allowUnfreePackages = [
        "1password"
        "1password-cli"
      ];

      programs = {
        _1password.enable = true;

        _1password-gui = {
          enable = true;

          polkitPolicyOwners = lib.attrNames config.users.users;
        };

        firefox.policies.ExtensionSettings."{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
}
