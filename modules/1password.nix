{ lib, config, pkgs, ... }:

with lib;

{
  options._1password = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable 1password on the system level.
      '';
    };
    polkitPolicyOwners = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Which users should be able to use 1password GUI integrations.
      '';
    };
    allowedBrowsers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Which browsers should be able to integrate with 1password.
      '';
    };
  };

  config = mkIf config._1password.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = config._1password.polkitPolicyOwners;
    };

    environment.etc = mkIf ( config._1password.allowedBrowsers != [] ) {
      "1password/custom_allowed_browsers" = {
        text = foldr (el: acc: el + "\n" + acc) "" config._1password.allowedBrowsers;
        mode = "0644";
      };
    };
  };
}
