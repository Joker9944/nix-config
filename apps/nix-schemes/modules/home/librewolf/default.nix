flake:
{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.schemes.librewolf =
    let
      inherit (lib) mkEnableOption mkOption types;
      customTypes = flake.lib.types;
    in
    {
      enable = mkEnableOption "librewolf theming based on custom theme";

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to theme librewolf theme.
        '';
      };

      profiles = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Profiles where the theme should be installed to.
        '';
      };

      addonId = mkOption {
        type = types.str;
        default = "nix-schemes-theme@localhost";
        description = ''
          Firefox extension ID for the custom theme.
        '';
      };
    };

  config =
    let
      cfg = config.schemes.librewolf;

      themeExtensionPackage = pkgs.callPackage (
        { stdenvNoCC, zip, ... }:
        stdenvNoCC.mkDerivation {
          name = "firefox-${cfg.scheme.name}-theme";

          nativeBuildInputs = [ zip ];

          manifest = import ./templates/manifest.json.nix cfg;
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
