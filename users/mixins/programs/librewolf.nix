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

          profiles =
            let
              inherit (custom.config) username;
              usernameLower = lib.toLower username;
            in
            {
              ${username} = {
                id = 0;
                name = lib.mkIf (username != usernameLower) usernameLower;
                isDefault = true;
              };
            };

          policies = {
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
            Preferences = {
              "browser.profiles.enabled" = {
                Value = true;
                Status = "default";
                Type = "boolean";
              };
            };
          };
        };

        firefoxpwa.package = pkgs.firefoxpwa-unwrapped.override {
          firefoxRuntime = pkgs.librewolf-unwrapped;
        };
      };

      custom.browser-dispatcher.defaultBrowserCommand = "librewolf --name librewolf \"$URL\"";

      xdg.mimeApps.custom.apps.default = [
        "${config.programs.librewolf.finalPackage}/share/applications/librewolf.desktop"
      ];
    };
}
