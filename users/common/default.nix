{
  inputs,
  custom,
  osConfig,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

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
}
