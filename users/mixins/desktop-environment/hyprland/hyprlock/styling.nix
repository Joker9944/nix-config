{
  lib,
  config,
  custom,
  ...
}:
custom.lib.mkHyprlandModule config {
  programs.hyprlock.settings =
    let
      cfg = config.windowManager.hyprland.custom.style;
      inherit (cfg) border fonts scheme;
    in
    {
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

        inner_color = scheme.background.normal.rgba 0.93;
        outer_color = scheme.accent.rgba 0.93;
        check_color = scheme.info.rgba 0.93;
        fail_color = scheme.error.rgba 0.93;

        font_color = scheme.foreground.normal.rgb;
        font_family = lib.mkIf (fonts.interface != null) fonts.interface.name;

        dots_spacing = 0.3;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };

      image =
        let
          inputFieldCfg = config.programs.hyprlock.settings.input-field;
        in
        [
          (
            {
              # User avatar
              path = "${custom.assets.images.profile.the-seer."512x512"}/share/profile/the-seer.512x512.jpg";

              border_size = border.size;
              border_color = scheme.background.normal.rgba 0.93;

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
}
