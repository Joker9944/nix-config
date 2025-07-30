{
  config,
  lib,
  ...
}: let
  cfg = config.programs._1password;
in {
  options.programs._1password = with lib; {
    additionalPolkitPolicyOwners = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Which users should be able to use 1password GUI integrations.
      '';
    };

    additionalAllowedBrowsers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Which browsers should be able to integrate with 1password which are not automatically detected.
      '';
    };
  };

  config = lib.mkIf config.programs._1password-gui.enable {
    programs._1password.enable = true;

    programs._1password-gui = {
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = (builtins.attrNames config.users.users) ++ cfg.additionalPolkitPolicyOwners;
    };

    environment.etc."1password/custom_allowed_browsers".text = let
      browsers =
        cfg.additionalAllowedBrowsers
        ++ lib.optional config.programs.firefox.enable "firefox";
    in
      lib.mkIf (browsers != []) (lib.concatLines browsers);
  };
}
