{
  lib,
  config,
  ...
}:
let
  cfg = config.gnome-settings.appearance;

  backgroundOptions = _: {
    options = with lib; {
      picturePath = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
        description = ''
          File path of the image used as wallpaper. If not set the color config will be used.
        '';
      };
      darkStylePicturePath = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
        description = ''
          File path of the image used as wallpaper in prefer-dark appearance style. If not set the main image path will be used as fallback.
        '';
      };
      pictureOption = mkOption {
        type = types.enum [
          "none"
          "wallpaper"
          "centered"
          "scaled"
          "stretched"
          "zoom"
          "spanned"
        ];
        default = "zoom";
        description = ''
          Determines how the image is rendered.
        '';
      };
      pictureOpacity = mkOption {
        type = types.ints.between 0 100;
        default = 100;
        description = ''
          Opacity with which to draw the background picture.
        '';
      };
      colorShadingType = mkOption {
        type = types.enum [
          "horizontal"
          "vertical"
          "solid"
        ];
        default = "solid";
        description = ''
          How to shade the background color.
        '';
      };
      primaryColor = mkOption {
        type = types.str;
        default = "#023c88";
        description = ''
          Left or Top color when drawing gradients, or the solid color.
        '';
      };
      secondaryColor = mkOption {
        type = types.str;
        default = "#5789ca";
        description = ''
          Right or Bottom color when drawing gradients, not used for solid color.
        '';
      };
    };
  };
in
{
  options.gnome-settings.appearance = with lib; {
    enable = mkEnableOption "Whether to enable GNOME appearance config.";

    style = mkOption {
      type = types.enum [
        "default"
        "prefer-dark"
      ];
      default = "default";
      description = ''
        The style used for the GNOME shell.
      '';
    };

    gtkLegacyCompatibility = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable legacy GTK application style compatibility.
      '';
    };

    accentColor = mkOption {
      type = types.enum [
        "blue"
        "teal"
        "green"
        "yellow"
        "orange"
        "red"
        "pink"
        "purple"
        "slate"
      ];
      default = "purple";
      description = ''
        The accent color used for the GNOME shell.
      '';
    };

    background = mkOption {
      type = types.nullOr (types.submodule backgroundOptions);
      default = null;
      example = lib.literalExpression ''
        {
          picturePath = "/run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
          pictureDarkStylePath = "/run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
          pictureOption = "zoom";
          pictureOpacity = 100;
          colorShadingType = "solid";
          primaryColor = "#023c88";
          secondaryColor = "#5789ca";
        }
      '';
      description = ''
        Desktop background config.
      '';
    };
  };

  config =
    let
      mkBackgroundDconfSettings = {
        picture-options = cfg.background.pictureOption;
        color-shading-type = cfg.background.colorShadingType;
        primary-color = cfg.background.primaryColor;
        secondary-color = cfg.background.secondaryColor;
      }
      // lib.attrsets.optionalAttrs (cfg.background.picturePath != null) {
        picture-uri = "file://${cfg.background.picturePath}";
      };
      mkBackgroundWithDarkDconfSettings =
        mkBackgroundDconfSettings
        //
          lib.attrsets.optionalAttrs
            (cfg.background.picturePath != null && cfg.background.darkStylePicturePath == null)
            {
              picture-uri-dark = "file://${cfg.background.picturePath}";
            }
        //
          lib.attrsets.optionalAttrs
            (cfg.background.picturePath != null && cfg.background.darkStylePicturePath != null)
            {
              picture-uri-dark = "file://${cfg.background.darkStylePicturePath}";
            };
    in
    lib.mkIf cfg.enable {
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = cfg.style;
          accent-color = cfg.accentColor;
        };

        "org/gnome/desktop/background" = lib.mkIf (
          cfg.background != null
        ) mkBackgroundWithDarkDconfSettings;
        "org/gnome/desktop/screensaver" = lib.mkIf (cfg.background != null) mkBackgroundDconfSettings;
      };

      gtk = lib.mkIf cfg.gtkLegacyCompatibility {
        enable = true;

        gtk3.extraConfig.gtk-application-prefer-dark-theme = if (cfg.style == "default") then 0 else 1;
      };
    };
}
