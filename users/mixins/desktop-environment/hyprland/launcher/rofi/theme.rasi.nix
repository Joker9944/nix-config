{ cfg, rasi, ... }:
let
  inherit (cfg.style) scheme opacity border;
  inherit (rasi) mkLiteral;
  font = cfg.style.fonts.interface;
in
{
  # cSpell:words rasi mainbox inputbar listview
  "*" = {
    font = "${font.name} ${toString font.size}";
    text-color = mkLiteral scheme.named.foreground.normal.rgb;
    background-color = mkLiteral "transparent";
  };

  window = {
    background-color = mkLiteral (scheme.named.background.normal.rgba opacity.active);
    border = mkLiteral "${toString border.size}px";
    border-radius = mkLiteral "${toString border.corners.rounding}px";
    border-color = mkLiteral (scheme.custom.accent.rgba 0.93);
  };

  mainbox = {
    padding = mkLiteral "12px";
  };

  inputbar = {
    children = [
      "prompt"
      "textbox-bar"
      "entry"
      "case-indicator"
    ];

    font = "${font.name} Bold ${toString font.size}";

    background-color = mkLiteral scheme.named.background.light.rgb;

    padding = mkLiteral "5px";

    border = mkLiteral "1px";
    border-radius = mkLiteral "${toString border.corners.rounding}px";
    border-color = mkLiteral scheme.named.background.lighter.rgb;
  };

  prompt = {
    font = mkLiteral "inherit";

    margin = mkLiteral "0 5px 0 0";
  };

  textbox-bar = {
    margin = mkLiteral "0 5px 0 0";

    expand = false;
    str = "»";
  };

  entry = {
    placeholder = "search";
  };

  listview = {
    margin = mkLiteral "5px 0 0 0";

    spacing = mkLiteral "2px";
    fixed-height = false;
  };

  element = {
    padding = mkLiteral "5px";
    border-radius = mkLiteral "${toString border.corners.rounding}px";
  };

  "element selected" = {
    background-color = mkLiteral (scheme.custom.accent.rgba opacity.active);
  };

  "element normal.active, element selected.active" = {
    text-color = mkLiteral scheme.named.info.rgb;
  };

  "element normal.urgent, element selected.urgent" = {
    text-color = mkLiteral scheme.named.error.rgb;
  };

  element-icon = {
    size = mkLiteral "1.6em";
  };

  element-text = {
    text-color = mkLiteral "inherit";
    vertical-align = mkLiteral "0.5";
  };
}
