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
      inherit (lib)
        mkEnableOption
        mkOption
        types
        literalExpression
        ;
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

      accent = mkOption {
        type = types.nullOr (types.functionTo customTypes.color);
        default = _: config.schemes.scheme.accent;
        defaultText = literalExpression ''
          colorLib: config.schemes.scheme.accent
        '';
        example = literalExpression ''
          colorLib: colorLib.mkColor [ 0 127 255 ]
        '';
        description = ''
          Custom accent color to override accent colors derived from scheme.
        '';
      };

      overrides.theme = mkOption {
        type = types.nullOr (types.attrsOf types.str);
        default = null;
        example = literalExpression ''

        '';
        description = ''

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
