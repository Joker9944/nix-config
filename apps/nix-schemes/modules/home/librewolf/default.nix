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
          inherit (cfg.scheme) palette accent;
        in
        {
          frame = mkColorOption palette.base01 "active frame background";
          frame_inactive = mkColorOption palette.base00 "inactive frame background";

          tab_line = mkColorOption palette.base01 "tab border";
          tab_selected = mkColorOption palette.base00 "active tab background";
          tab_text = mkColorOption palette.base05 "active tab text";
          tab_background_text = mkColorOption palette.base05 "general tab text";
          tab_background_separator = mkColorOption palette.base02 "separator between background tabs";
          tab_loading = mkColorOption accent "tab loading indicator";

          toolbar = mkColorOption palette.base00 "navigation bar background";
          toolbar_text = mkColorOption palette.base05 "navigation bar text";
          toolbar_top_separator = mkColorOption palette.base01 "line above the navigation bar";
          toolbar_bottom_separator = mkColorOption palette.base01 "line below the navigation bar";
          toolbar_vertical_separator = mkColorOption palette.base02 "separator between navigation bar buttons";

          toolbar_field = mkColorOption palette.base01 "navigation field background";
          toolbar_field_text = mkColorOption palette.base05 "navigation field text";
          toolbar_field_border = mkColorOption palette.base02 "navigation field border";
          toolbar_field_focus = mkColorOption palette.base02 "focused navigation field background";
          toolbar_field_text_focus = mkColorOption palette.base05 "focused navigation field text";
          toolbar_field_border_focus = mkColorOption accent "focused element";
          toolbar_field_highlight = mkColorOption accent "navigation field selection background";
          toolbar_field_highlight_text = mkColorOption palette.base00 "navigation field selection text";

          button_background_hover = mkColorOption palette.base01 "hovered button background";
          button_background_active = mkColorOption palette.base02 "pressed button background";

          icons = mkColorOption palette.base04 "navigation bar icons";
          icons_attention = mkColorOption accent "navigation bar icons demanding attention";

          popup = mkColorOption palette.base00 "menu background";
          popup_border = mkColorOption palette.base01 "menu border";
          popup_text = mkColorOption palette.base05 "menu text";
          popup_highlight = mkColorOption palette.base02 "selected menu row background";
          popup_highlight_text = mkColorOption palette.base05 "selected menu row text";

          sidebar = mkColorOption palette.base00 "sidebar background";
          sidebar_text = mkColorOption palette.base05 "sidebar text";
          sidebar_border = mkColorOption palette.base01 "sidebar border";
          sidebar_highlight = mkColorOption accent "selected sidebar row background";
          sidebar_highlight_text = mkColorOption palette.base00 "selected sidebar row text";

          ntp_background = mkColorOption palette.base00 "new tab page background";
          ntp_text = mkColorOption palette.base05 "new tab page text";
          ntp_card_background = mkColorOption palette.base01 "new tab page card background";
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

          manifest = import ./manifest.nix { inherit (cfg) scheme addonId colors; };
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
