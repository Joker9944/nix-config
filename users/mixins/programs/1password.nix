{
  lib,
  config,
  osConfig,
  custom,
  ...
}:
{
  options.mixins.programs._1password =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "1Password config mixin";

      vault = mkOption {
        type = types.str;
        default = "Private";
      };
    };

  config =
    let
      cfg = config.mixins.programs._1password;
    in
    lib.mkIf cfg.enable {
      programs = {
        _1password = {
          enable = true;

          blocks = [ "*" ];

          sshAgentConfig.ssh-keys = [
            {
              inherit (cfg) vault;
              item = "${custom.config.username}@${osConfig.networking.hostName}";
            }
          ];

          autostart.enable = true;
        };

        firefox.policies.ExtensionSettings."{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
}
