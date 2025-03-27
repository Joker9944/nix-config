{
  config,
  lib,
  ...
}: {
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
        Which browsers should be able to integrate with 1password.
      '';
    };
  };

  config = with lib;
    mkIf config.programs._1password-gui.enable {
      programs._1password.enable = true;
      programs._1password-gui = {
        # Certain features, including CLI integration and system authentication support,
        # require enabling PolKit integration on some desktop environments (e.g. Plasma).
        polkitPolicyOwners = (builtins.attrNames config.users.users) ++ config.programs._1password.additionalPolkitPolicyOwners;
      };

      environment.etc = let
        detectFirefox =
          if (config.programs.firefox.enable)
          then ["firefox"]
          else [];
        browsers = detectFirefox ++ config.programs._1password.additionalAllowedBrowsers;
      in
        mkIf (browsers != []) {
          "1password/custom_allowed_browsers" = {
            text = foldr (el: acc: el + "\n" + acc) "" browsers;
            mode = "0644";
          };
        };
    };
}
