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
  services.home-manager.autoUpgrade = {
    inherit (osConfig.system.autoUpgrade)
      enable
      persistent
      dates
      flake
      ;
    notify.enable = true;
  };
}
