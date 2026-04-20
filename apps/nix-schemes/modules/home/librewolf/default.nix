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

      overrides.theme = mkOption {
        type = types.nullOr (types.attrsOf types.str);
        default = null;
        example = literalExpression ''
          {
            frame = "#1e1e2e";
            toolbar = "#181825";
            toolbar_field_border_focus = "#cba6f7";
          }
        '';
        description = ''
          Overrides specific theme colors in the generated Firefox theme manifest.
          Available color keys include: frame, frame_inactive, tab_line, tab_background_text,
          toolbar, toolbar_text, toolbar_field, toolbar_field_text, toolbar_field_border_focus,
          popup, popup_border, popup_text.
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
