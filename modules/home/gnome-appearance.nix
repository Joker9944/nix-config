{
  lib,
  config,
  ...
}: let
  cfg = config.gnome-settings.appearance;
in {
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
  };

  config = lib.mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = cfg.style;
        accent-color = cfg.accentColor;
      };
    };

    gtk = lib.mkIf cfg.gtkLegacyCompatibility {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme =
        if (cfg.style == "default")
        then 0
        else 1;
    };
  };
}
