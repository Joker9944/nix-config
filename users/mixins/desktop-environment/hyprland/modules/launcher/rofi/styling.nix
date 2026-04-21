{ mkHyprlandModule, ... }:
{ config, ... }:
let
  cfg = config.mixins.desktopEnvironment.hyprland.style;

  font = cfg.fonts.interface;
  inherit (cfg) opacity border;

  inherit (config.lib.formats.rasi) mkLiteral;
in
mkHyprlandModule {
  programs.wallust.templates.rofi = {
    enable = true;

    template = {
      "*" = {
        font = "${font.name} ${toString font.size}";
        text-color = mkLiteral "rgb({{foreground | rgb}})";
        background-color = mkLiteral "transparent";
      };

      window = {
        background-color = mkLiteral "rgba({{background | rgb}},${toString opacity.active})";
        border = mkLiteral "${toString border.size}px";
        border-radius = mkLiteral "${toString border.corners.rounding}px";
        border-color = mkLiteral "rgba({{color14 | rgb}},0.93)"; # TODO actual accent
      };

      mainbox = {
        # cSpell:words mainbox
        padding = mkLiteral "12px";
      };

      inputbar = {
        # cSpell:words inputbar
        children = [
          "prompt"
          "textbox-bar"
          "entry"
          "case-indicator"
        ];

        font = "${font.name} Bold ${toString font.size}";

        background-color = mkLiteral "rgb({{color1 | rgb}})";

        padding = mkLiteral "5px";

        border = mkLiteral "1px";
        border-radius = mkLiteral "${toString border.corners.rounding}px";
        border-color = mkLiteral "rgb({{color2 | rgb}})";
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
        # cSpell:words listview
        margin = mkLiteral "5px 0 0 0";

        spacing = mkLiteral "2px";
        fixed-height = false;
      };

      element = {
        padding = mkLiteral "5px";
        border-radius = mkLiteral "${toString border.corners.rounding}px";
      };

      "element selected" = {
        background-color = mkLiteral "rgba({{color14 | rgb}},${toString opacity.active})"; # TODO actual accent
      };

      "element normal.active, element selected.active" = {
        text-color = mkLiteral "rgb({{color11 | rgb}})";
      };

      "element normal.urgent, element selected.urgent" = {
        text-color = mkLiteral "rgb({{color8 | rgb}})";
      };

      element-icon = {
        size = mkLiteral "1.6em";
      };

      element-text = {
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };
    };
  };
}
