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

  /*
    xdg.mimeApps.custom.default =
    let
      desktopFile = utility.custom.first (utility.custom.lookupDesktopFiles package);
    in
    {
      applications = {
        x-extension-htm = [ desktopFile ];
        x-extension-html = [ desktopFile ];
        x-extension-shtml = [ desktopFile ];
        x-extension-xhtml = [ desktopFile ];
        x-extension-xht = [ desktopFile ];
      };

      x-scheme-handler = {
        http = [ desktopFile ];
        https = [ desktopFile ];
        chrome = [ desktopFile ];
      };

      text.html = [ desktopFile ];
    };
  */
}
