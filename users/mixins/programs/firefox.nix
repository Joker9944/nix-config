{ mkMixinModule, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
mkMixinModule "firefox" {
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
}
