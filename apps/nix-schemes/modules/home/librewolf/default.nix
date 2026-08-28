flake:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  libSchemes = flake.lib.libSchemes;
in
{
  options.schemes.librewolf =
    let
      inherit (lib) mkEnableOption mkOption types;
      customTypes = libSchemes.types;

      cfg = config.schemes.librewolf;

      mkColorOption =
        default: slot:
        mkOption {
          inherit default;
          type = customTypes.color;
          description = ''
            Color of the ${slot}.
          '';
        };
    in
    {
      enable = mkEnableOption "librewolf theming based on custom theme";

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to theme librewolf.
        '';
      };

      profiles = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          librewolf profiles where the theme should be installed to.
        '';
      };

      addonId = mkOption {
        type = types.str;
        default = "nix-schemes-theme@localhost";
        description = ''
          Firefox extension ID for the custom theme.
        '';
      };

      # https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/theme#colors
      colors =
        let
          inherit (cfg.scheme) palette;
        in
        {
          frame = mkColorOption palette.base01 "active frame background";
          frame_inactive = mkColorOption palette.base00 "inactive frame background";
          tab_line = mkColorOption palette.base01 "tab border";
          tab_background_text = mkColorOption palette.base05 "general tab text";
          toolbar = mkColorOption palette.base00 "navigation bar background";
          toolbar_text = mkColorOption palette.base05 "navigation bar text";
          toolbar_field = mkColorOption palette.base01 "navigation field background";
          toolbar_field_text = mkColorOption palette.base05 "navigation field text";
          toolbar_field_border_focus = mkColorOption cfg.scheme.accent "focused element";
          popup = mkColorOption palette.base00 "menu background";
          popup_border = mkColorOption palette.base01 "menu border";
          popup_text = mkColorOption palette.base05 "menu text";
        };
    };

  config =
    let
      cfg = config.schemes.librewolf;

      themeExtensionPackage = pkgs.callPackage (
        { stdenv, zip, ... }:
        stdenv.mkDerivation {
          name = "firefox-${cfg.scheme.meta.name}-theme";

          nativeBuildInputs = [ zip ];

          manifest = import ./templates/manifest.json.nix {
            inherit (cfg) scheme addonId colors;
          };
          passAsFile = [ "manifest" ];

          dontUnpack = true;
          preferLocalBuild = true;

          buildPhase = ''
            runHook preBuild

            mkdir -p ext
            cp "$manifestPath" ext/manifest.json
            (cd ext && zip -r ../${cfg.addonId}.xpi .)

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
            mkdir -p "$dst"
            install --mode=644 "${cfg.addonId}.xpi" "$dst/${cfg.addonId}.xpi"

            runHook postInstall
          '';
        }
      ) { };
    in
    lib.mkIf cfg.enable {
      programs.librewolf = {
        enable = lib.mkDefault true;

        profiles = lib.pipe cfg.profiles [
          (lib.map (profile: {
            name = profile;
            value = {
              extensions.packages = [ themeExtensionPackage ];
            };
          }))
          lib.listToAttrs
        ];
      };
    };
}
