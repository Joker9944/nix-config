{ osConfig, ... }:
let
  inherit (osConfig.programs.firefox) package;
in
{
  programs.firefox = {
    enable = true;
    inherit package;
  };

  services.firefox-profile-switcher-connector.enable = true;

  xdg.mimeApps.custom.apps.default = [ "${package}/share/applications/firefox.desktop" ];
}
