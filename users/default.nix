{
  lib,
  config,
  custom,
  osConfig,
  ...
}:
let
  userSecrets = lib.path.append ./. "${custom.config.username}/secrets.yaml";
in
{
  imports = [
    (lib.path.append ./. custom.config.username)
  ];

  # Set args inherited from mkHomeConfiguration
  home = {
    inherit (custom.config) username;
    homeDirectory = "/home/${custom.config.username}";
  };

  # Enable automatic upgrades
  services.customAutoUpgrade = {
    inherit (osConfig.system.autoUpgrade)
      enable
      persistent
      dates
      flake
      notify
      ;
  };

  # Setup sops if user secrets file exists
  sops = lib.mkIf (builtins.pathExists userSecrets) {
    defaultSopsFile = userSecrets;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
