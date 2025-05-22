{
  lib,
  config,
  ...
}: let
  cfg = config.gnome-tweaks.fonts;

  defaultFontSize = 10;
  injectDefaults = fontConfig:
    fontConfig
    // lib.attrsets.optionalAttrs (fontConfig.size == null) {
      size = defaultFontSize;
    };

  optionalPackage = opt: lib.optional (opt != null && opt.package != null) opt.package;
in {
  options.gnome-tweaks.fonts = with lib; {
    enable = mkEnableOption "Whether to enable GNOME fonts config.";

    interfaceText = mkOption {
      type = types.nullOr lib.hm.types.fontType;
      default = null;
      description = ''
        Preferred interface text font.
      '';
    };

    gtkFontCompatibility = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether the interface text font should be used for GTK applications.
      '';
    };

    documentText = mkOption {
      type = types.nullOr lib.hm.types.fontType;
      default = null;
      description = ''
        Preferred document text font.
      '';
    };

    monospaceText = mkOption {
      type = types.nullOr lib.hm.types.fontType;
      default = null;
      description = ''
        Preferred monospace text font.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    let
      dconfSettings =
        lib.attrsets.optionalAttrs (cfg.interfaceText != null && !cfg.gtkFontCompatibility) {
          font-name = "${cfg.interfaceText.name} ${toString (injectDefaults cfg.interfaceText).size}";
        }
        // lib.attrsets.optionalAttrs (cfg.documentText != null) {
          document-font-name = "${cfg.documentText.name} ${toString (injectDefaults cfg.documentText).size}";
        }
        // lib.attrsets.optionalAttrs (cfg.monospaceText != null) {
          monospace-font-name = "${cfg.monospaceText.name} ${toString (injectDefaults cfg.monospaceText).size}";
        };

      homePkgs =
        lib.lists.optional (cfg.interfaceText != null && !cfg.gtkFontCompatibility) cfg.interfaceText.package
        ++ lib.lists.optional (cfg.monospaceText != null) cfg.monospaceText.package
        ++ lib.lists.optional (cfg.monospaceText != null) cfg.monospaceText.package;
    in {
      dconf.settings."org/gnome/desktop/interface" = dconfSettings;

      home.packages = homePkgs;

      gtk = lib.mkIf (cfg.interfaceText != null && cfg.gtkFontCompatibility) {
        enable = true;

        font = cfg.interfaceText;
      };
    }
  );
}
