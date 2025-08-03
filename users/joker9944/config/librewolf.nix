{config, ...}: {
  programs = {
    librewolf = {
      enable = true;

      settings = {
        "identity.fxaccounts.enabled" = true;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
      };

      profiles = {
        "Joker9944" = {
          isDefault = true;
        };
      };
    };

    firefox-profile-switcher-connector.enable = config.programs.librewolf.enable;
  };
}
