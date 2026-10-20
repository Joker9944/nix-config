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
      (pkgs-unstable.firefoxpwa-unwrapped.override {
        firefoxRuntime = pkgs.librewolf-unwrapped;
      }).overrideAttrs
        (prev: {
          # HACK https://github.com/NixOS/nixpkgs/issues/570721
          # 2.20.0 and older statically import chrome modules that Gecko 158 moved to moz-src:; the
          # failed import takes the whole PWA chrome layer with it and the runtime segfaults at
          # launch. src is restated rather than rehashed because overriding only the hash leaves the
          # realised fetch, and its tag, untouched.
          version = "2.20.1";
          src = pkgs.fetchFromGitHub {
            owner = "filips123";
            repo = "PWAsForFirefox";
            tag = "v2.20.1";
            hash = "sha256-kOtdGRW2DN0qQLrtvbsywBdGlM/1cboQGu2NM7cO8E8=";
          };

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
