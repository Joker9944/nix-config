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

    firefoxpwa.package = pkgs.wrapFirefox (pkgs.firefoxpwa-unwrapped.overrideAttrs (prev: {
      passthru =
        prev.passthru // lib.filterAttrs (name: _: lib.hasSuffix "Support" name) pkgs.firefox-unwrapped;
    })) { };
  };

  xdg.mimeApps.custom.apps.default = [
    "${config.programs.firefox.finalPackage}/share/applications/firefox.desktop"
  ];
}
