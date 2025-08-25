{
  lib,
  config,
  utility,
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
        type = types.nullOr (
          types.enum [
            "none"
            "wallpaper"
            "centered"
            "scaled"
            "stretched"
            "zoom"
            "spanned"
          ]
        );
        default = null;
        description = ''
          Determines how the image is rendered.
        '';
      };

      pictureOpacity = mkOption {
        type = types.nullOr (types.ints.between 0 100);
        default = null;
        description = ''
          Opacity with which to draw the background picture.
        '';
      };

      colorShadingType = mkOption {
        type = types.nullOr (
          types.enum [
            "horizontal"
            "vertical"
            "solid"
          ]
        );
        default = null;
        description = ''
          How to shade the background color.
        '';
      };

      primaryColor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Left or Top color when drawing gradients, or the solid color.
        '';
      };

      secondaryColor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Right or Bottom color when drawing gradients, not used for solid color.
        '';
      };
    };
  };
in
{
  options.gnome-settings.appearance = with lib; {
    enable = mkEnableOption "GNOME appearance config";

    style = mkOption {
      type = types.nullOr (
        types.enum [
          "default"
          "prefer-dark"
          "prefer-light"
        ]
      );
      default = null;
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
      type = types.nullOr (
        types.enum [
          "blue"
          "teal"
          "green"
          "yellow"
          "orange"
          "red"
          "pink"
          "purple"
          "slate"
        ]
      );
      default = null;
      description = ''
        The accent color used for the GNOME shell.
      '';
    };

    background = mkOption {
      type = types.submodule backgroundOptions;
      default = { };
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

  config = lib.mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = utility.custom.nonNull cfg.style;
        accent-color = utility.custom.nonNull cfg.accentColor;
      };

      "org/gnome/desktop/background" =
        with cfg.background;
        let
          mkPicturePath = path: "file://${path}";
        in
        {
          picture-options = utility.custom.nonNull pictureOption;
          color-shading-type = utility.custom.nonNull colorShadingType;
          primary-color = utility.custom.nonNull primaryColor;
          secondary-color = utility.custom.nonNull secondaryColor;
          picture-uri = lib.mkIf (picturePath != null) (mkPicturePath picturePath);
          picture-uri-dark = lib.mkIf (picturePath != null || darkStylePicturePath != null) (
            mkPicturePath (if darkStylePicturePath != null then darkStylePicturePath else picturePath)
          );
        };
    };

    gtk = lib.mkIf cfg.gtkLegacyCompatibility {
      enable = true;

      gtk3.extraConfig.gtk-application-prefer-dark-theme = if (cfg.style != "prefer-dark") then 0 else 1;
    };
  };
}
