{ mkMixinModule, ... }:
{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
mkMixinModule "librewolf" {
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
          inherit (config.home) username;
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

    firefoxpwa.package = pkgs.wrapFirefox (
      # HACK on unstable until https://github.com/NixOS/nixpkgs/issues/570721 lands; 2.20.0 and older
      # segfault on Gecko 158
      (pkgs-unstable.firefoxpwa-unwrapped.override {
        firefoxRuntime = pkgs.librewolf-unwrapped;
      }).overrideAttrs
        (prev: {
          passthru =
            prev.passthru // lib.filterAttrs (name: _: lib.hasSuffix "Support" name) pkgs.librewolf-unwrapped;
        })
    ) { };
  };

  custom.browser-dispatcher.defaultBrowserCommand = "librewolf --name librewolf \"$URL\"";

  xdg.mimeApps.custom.apps.default = [
    "${config.programs.librewolf.finalPackage}/share/applications/librewolf.desktop"
  ];
}
