{
  inputs,
  custom,
  osConfig,
  utility,
  ...
}:
{
  imports =
    (utility.custom.ls.lookup {
      dir = ./.;
      exclude = [ ./default.nix ];
    })
    ++ [ inputs.sops-nix.homeManagerModules.sops ];

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

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
    };

    home-manager.enable = true;

    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        pull.rebase = false;
      };
    };
  };
}
