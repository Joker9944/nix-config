{
  lib,
  config,
  customConfig,
  osConfig,
  ...
}: let
  userSecrets = lib.path.append ./. "${customConfig.username}/secrets.yaml";
in {
  imports = [
    (lib.path.append ./. customConfig.username)
  ];

  # Set args inherited from mkHomeConfiguration
  home = {
    username = customConfig.username;
    homeDirectory = "/home/${customConfig.username}";
  };

  # Enable automatic upgrades
  services.betterAutoUpgrade = {
    inherit (osConfig.system.autoUpgrade) enable persistent flake notify;
    frequency = osConfig.system.autoUpgrade.dates;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Setup sops if user secrets file exists
  sops = lib.mkIf (builtins.pathExists userSecrets) {
    defaultSopsFile = userSecrets;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
