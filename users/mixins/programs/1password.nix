{ mkMixinModule, ... }:
{ osConfig, custom, ... }:
let
  extension."{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
    installation_mode = "force_installed";
  };
in
mkMixinModule "_1password" {
  programs = {
    _1password = {
      enable = true;

      blocks = [ "*" ];

      sshAgentConfig.ssh-keys = [
        {
          vault = "Private";
          item = "${custom.config.username}@${osConfig.networking.hostName}";
        }
      ];

      autostart.enable = true;
    };

    firefox.policies.ExtensionSettings = extension;
    librewolf.policies.ExtensionSettings = extension;
  };
}
