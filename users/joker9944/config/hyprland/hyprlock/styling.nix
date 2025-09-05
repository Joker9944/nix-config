{
  lib,
  config,
  utility,
  custom,
  ...
}:
utility.custom.mkHyprlandModule config {
  programs.hyprlock.settings = with config.windowManager.hyprland.custom.style; {
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
      inherit (border.corners) rounding;

      size = "20%, 5%";
      outline_thickness = border.size;

      inner_color = pallet.background.normal.rgba 0.93;
      outer_color = pallet.functional.focus.rgba 0.93;
      check_color = pallet.functional.info.rgba 0.93;
      fail_color = pallet.functional.danger.rgba 0.93;

      font_color = pallet.foreground.rgb;
      font_family = lib.mkIf (font != null) font.name;

      dots_spacing = 0.3;

      position = "0, -20";
      halign = "center";
      valign = "center";
    };

    image = let
      inputFieldCfg = config.programs.hyprlock.settings.input-field;
    in [
      ({
        # User avatar
        path = "${custom.assets.images.profile.the-seer."512x512"}/share/profile/the-seer.512x512.jpg";

        border_size = border.size;
        border_color = pallet.background.normal.rgba 0.93;

        size = "150";
        position = "0, 130";
      } // lib.optionalAttrs (lib.hasAttr "monitor" inputFieldCfg) {inherit (inputFieldCfg) monitor;})
    ];

    label = [
      {
        # Time
        text = "$TIME"; # ref. https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
        font_size = 90;
        font_family = lib.mkIf (font != null) font.name;

        position = "-30, 0";
        halign = "right";
        valign = "top";
      }
      {
        # Date
        text = "cmd[update:60000] date +\"%A, %d %B %Y\""; # update every 60 seconds
        font_size = 25;
        font_family = lib.mkIf (font != null) font.name;

        position = "-30, -150";
        halign = "right";
        valign = "top";
      }
    ];
  };
}
