{ lib, config, ... }:
let
  cfg = config.sops;
in
{
  options.sops.secretHome =
    with lib;
    mkOption {
      type = types.str;
      default = "${config.xdg.configHome}/sops-nix/secrets";
      description = ''
        Absolute path to directory holding sops secrets.

        Sets `SOPS_SECRETS_HOME` for the user if secrets are specified.
      '';
    };

  config = lib.mkIf (cfg.secrets != { }) {
    home.sessionVariables.SOPS_SECRETS_HOME = cfg.secretHome;
  };
}
