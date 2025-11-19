{ cfg, rasi, ... }:
let
  inherit (cfg) style;
  inherit (rasi) mkLiteral;
in
{
  # cSpell:words rasi mainbox inputbar listview
  "*" = {
    font =
      let
        inherit (style) font;
      in
      "${font.name} ${toString font.size}";
    text-color = mkLiteral style.pallet.cursor.rgb;
    background-color = mkLiteral "transparent";
  };

  window = {
    background-color = mkLiteral (style.pallet.background.normal.rgba style.opacity.active);
    border = mkLiteral "${toString style.border.size}px";
    border-radius = mkLiteral "${toString style.border.corners.rounding}px";
    border-color = mkLiteral (style.pallet.functional.focus.rgba 0.93);
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

    font =
      let
        inherit (style) font;
      in
      "${font.name} Bold ${toString font.size}";

    background-color = mkLiteral style.pallet.background.light.rgb;

    padding = mkLiteral "5px";

    border = mkLiteral "1px";
    border-radius = mkLiteral "${toString style.border.corners.rounding}px";
    border-color = mkLiteral style.pallet.background.lighter.rgb;
  };

  prompt = {
    font = mkLiteral "inherit";

    margin = mkLiteral "0 5px 0 0";
  };

  textbox-bar = {
    margin = mkLiteral "0 5px 0 0";

    expand = false;
    str = ">";
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
    border-radius = mkLiteral "${toString style.border.corners.rounding}px";
  };

  "element selected" = {
    background-color = mkLiteral (style.pallet.functional.focus.rgba style.opacity.active);
  };

  "element normal.active, element selected.active" = {
    text-color = mkLiteral style.pallet.blue.dull.rgb;
  };

  "element normal.urgent, element selected.urgent" = {
    text-color = mkLiteral style.pallet.red.dull.rgb;
  };

  element-icon = {
    size = mkLiteral "1.6em";
  };

  element-text = {
    text-color = mkLiteral "inherit";
    vertical-align = mkLiteral "0.5";
  };
}
