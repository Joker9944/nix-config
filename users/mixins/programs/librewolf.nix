{
  lib,
  pkgs,
  config,
  custom,
  ...
}:
{
  options.mixins.programs.librewolf =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "librewolf config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.librewolf;
    in
    lib.mkIf cfg.enable {
      programs = {
        librewolf = {
          enable = true;

          settings = {
            "identity.fxaccounts.enabled" = true; # cSpell:ignore fxaccounts
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.downloads" = false;
          };

          profiles = {
            ${custom.config.username} = {
              isDefault = true;
            };
          };

          policies = {
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
          };
        };

        firefoxpwa.package =
          (pkgs.firefoxpwa.override {
            firefoxRuntime = pkgs.librewolf-unwrapped;
          }).overrideAttrs
            (prev: {
              libs = "${config.programs.librewolf.finalPackage.libs}:${prev.libs}";
            });
      };

      services.firefox-profile-switcher-connector = {
        enable = true;
        browser = "librewolf";
      };

      xdg.mimeApps.custom.apps.default = [
        "${config.programs.librewolf.finalPackage}/share/applications/librewolf.desktop"
      ];
    };
}
