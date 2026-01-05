{
  lib,
  config,
  ...
}:
{
  options.mixins.programs.firefox =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "firefox config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.firefox;
    in
    lib.mkIf cfg.enable {
      programs.firefox = {
        enable = true;

        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
        };
      };

      services.firefox-profile-switcher-connector.enable = true;

      xdg.mimeApps.custom.apps.default = [
        "${config.programs.firefox.finalPackage}/share/applications/firefox.desktop"
      ];
    };
}
