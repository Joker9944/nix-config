flake:
{
  lib,
  config,
  ...
}:
let
  cfg = config.schemes.spicetify;
  libSchemes = flake.lib.libSchemes;
in
{
  options.schemes.spicetify =
    let
      inherit (lib) mkEnableOption mkOption;
      customTypes = libSchemes.types;

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
      enable = mkEnableOption "spicetify theming based on a scheme";

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to customize spicetify.
        '';
      };

      # The 18 slots of spicetify's `BaseColorList`. The set is closed — spicetify drops an
      # unknown key with a warning and substitutes its own stock-dark default for a missing
      # one, so both mistakes are silent unless the slots are declared.
      # https://spicetify.app/docs/development/themes
      colors =
        let
          inherit (cfg.scheme) palette accent status;
        in
        {
          text = mkColorOption palette.base05 "main field text, playlist names and headings";
          subtext = mkColorOption palette.base04 "sidebar buttons, artist names and mini infos";

          main = mkColorOption palette.base00 "main field background";
          main-elevated = mkColorOption palette.base01 "background of objects above the main field";

          # base24 has no slot between two backgrounds, and spicetify puts both highlights
          # there — a hover is a step short of the next elevation, not the elevation itself.
          highlight = mkColorOption (palette.base00.mix palette.base01 0.5) "hover background on the main field";
          highlight-elevated = mkColorOption (palette.base01.mix palette.base02 0.5) "hover background above the main field";

          sidebar = mkColorOption palette.base10 "sidebar background";
          player = mkColorOption palette.base10 "player background";
          card = mkColorOption palette.base02 "hovered card background and player area outline";
          shadow = mkColorOption palette.base11 "card drop shadow";

          selected-row = mkColorOption palette.base05 "selected song, scrollbar and playlist details";

          button = mkColorOption accent "play, like and sidebar playlist buttons";
          button-active = mkColorOption (accent.lighten 0.15) "active play button";
          button-disabled = mkColorOption palette.base03 "seekbar and volume bar track";

          tab-active = mkColorOption palette.base02 "active tabbar item background";

          notification = mkColorOption status.info "notification toast";
          notification-error = mkColorOption status.error "error notification toast";

          misc = mkColorOption palette.base04 "miscellaneous";
        };
    };

  config = lib.mkIf cfg.enable {
    programs.spicetify.customColorScheme = lib.mapAttrs (_: color: color.hex) cfg.colors;
  };
}
