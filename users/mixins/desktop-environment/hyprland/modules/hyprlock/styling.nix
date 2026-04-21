{ mkHyprlandModule, ... }:
{
  lib,
  config,
  custom,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland.style;
  inherit (cfg) border fonts;
in
mkHyprlandModule {
  programs.wallust.templates.hyprlock = {
    enable = true;

    template = {
      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fadeIn, 1, 5, linear"
          "fadeOut, 1, 5, linear"
          "inputFieldDots, 1, 2, linear"
        ];
      };

      background = {
        path = "screenshot";
        blur_passes = 3;
      };

      input-field = {
        fade_on_empty = false;

        placeholder_text = "Input password...";
        fail_text = "$PAMFAIL";

        inherit (border.corners) rounding;

        size = "20%, 5%";
        outline_thickness = border.size;

        inner_color = "rgba({{background | rgb}},0.93)";
        outer_color = "rgb({{color1 | saturate(0.6) | strip}}) rgb({{color2 | saturate(0.6) | strip}}) rgb({{color3 | saturate(0.6) | strip}}) rgb({{color4 | saturate(0.6) | strip}}) rgb({{color5 | saturate(0.6) | strip}}) rgb({{color6 | saturate(0.6) | strip}})";
        check_color = "rgba({{color11 | rgb}},0.93)";
        fail_color = "rgba({{color8 | rgb}},0.93)";

        font_color = "rgb({{cursor | rgb}})";
        font_family = lib.mkIf (fonts.interface != null) fonts.interface.name;

        dots_spacing = 0.3;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };

      image =
        let
          inputFieldCfg = config.programs.wallust.templates.hyprlock.template.input-field;
        in
        [
          (
            {
              # User avatar
              path = "${custom.assets.the-seer}";

              border_size = border.size;
              border_color = "rgba({{background | rgb}},0.93)";

              size = "150";
              position = "0, 130";
            }
            // lib.optionalAttrs (lib.hasAttr "monitor" inputFieldCfg) { inherit (inputFieldCfg) monitor; }
          )
        ];

      label = [
        {
          # Time
          text = "$TIME"; # ref. https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
          font_size = 90;
          font_family = lib.mkIf (fonts.interface != null) fonts.interface.name;

          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        {
          # Date
          text = "cmd[update:60000] date +\"%A, %d %B %Y\""; # update every 60 seconds
          font_size = 25;
          font_family = lib.mkIf (fonts.interface != null) fonts.interface.name;

          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];
    };
  };
}
