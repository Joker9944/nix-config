{
  lib,
  config,
  pkgs,
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
      programs = {
        firefox = {
          enable = true;

          policies = {
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
          };
        };

        firefoxpwa.package = lib.mkDefault (
          pkgs.firefoxpwa.overrideAttrs (prev: {
            libs = "${config.programs.firefox.finalPackage.libs}:${prev.libs}";
          })
        );
      };

      xdg.mimeApps.custom.apps.default = [
        "${config.programs.firefox.finalPackage}/share/applications/firefox.desktop"
      ];
    };
}
