{ osConfig, ... }:
{
  programs.firefox = {
    enable = true;
    inherit (osConfig.programs.firefox) package;
  };

  services.firefox-profile-switcher-connector.enable = true;
}
