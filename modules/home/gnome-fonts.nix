{
  lib,
  config,
  ...
}:
let
  cfg = config.gnome-tweaks.fonts;
in
{
  options.gnome-tweaks.fonts =
    with lib;
    let
      injectDefaultFontSize =
        opts:
        recursiveUpdate opts {
          size = {
            type = types.number;
            default = 11;
          };
        };
    in
    {
      enable = mkEnableOption "GNOME fonts config";

      interfaceText = injectDefaultFontSize (mkOption {
        type = types.nullOr lib.hm.types.fontType;
        default = null;
        description = ''
          Preferred interface text font.
        '';
      });

      gtkFontCompatibility = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether the interface text font should be used for GTK applications. Passes the interface text font to gtk.font.
        '';
      };

      documentText = injectDefaultFontSize (mkOption {
        type = types.nullOr lib.hm.types.fontType;
        default = null;
        description = ''
          Preferred document text font.
        '';
      });

      monospaceText = injectDefaultFontSize (mkOption {
        type = types.nullOr lib.hm.types.fontType;
        default = null;
        description = ''
          Preferred monospace text font.
        '';
      });
    };

  config = lib.mkIf cfg.enable {
    dconf.settings."org/gnome/desktop/interface" =
      let
        mkFontString = fontCfg: "${fontCfg.name} ${toString fontCfg.size}";
      in
      {
        font-name = lib.mkIf (cfg.interfaceText != null && !cfg.gtkFontCompatibility) (
          mkFontString cfg.interfaceText
        );
        document-font-name = lib.mkIf (cfg.documentText != null) (mkFontString cfg.documentText);
        monospace-font-name = lib.mkIf (cfg.monospaceText != null) (mkFontString cfg.monospaceText);
      };

    home.packages =
      lib.lists.optional (
        cfg.interfaceText != null && !cfg.gtkFontCompatibility
      ) cfg.interfaceText.package
      ++ lib.lists.optional (cfg.documentText != null) cfg.documentText.package
      ++ lib.lists.optional (cfg.monospaceText != null) cfg.monospaceText.package;

    gtk = lib.mkIf (cfg.interfaceText != null && cfg.gtkFontCompatibility) {
      enable = true;

      font = cfg.interfaceText;
    };
  };
}
