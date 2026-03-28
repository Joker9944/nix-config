# https://github.com/lassekongo83/adw-gtk3
# https://github.com/lassekongo83/adw-colors
flake:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  libScheme = flake.lib;
in
{
  options.schemes.gtk =
    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        types
        literalExpression
        ;
      customTypes = libScheme.types;
    in
    {
      enable = mkEnableOption "GTK theming based on adw-gtk3 and a scheme";

      theme.package = mkPackageOption pkgs "adw-gtk3" { };

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to customize adw-gtk3 theme.
        '';
      };

      accent = mkOption {
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
        default = "blue";
        description = ''
          The GTK accent color based on the GTK 4 accent system.
        '';
      };

      overrides.accent = mkOption {
        type = types.nullOr (types.functionTo customTypes.color);
        default = null;
        example = literalExpression "colorLib: colorLib.mkColor [ 0 127 255 ]";
        description = ''
          Custom accent color to override accent colors derived from scheme.
        '';
      };

      accentTransformer = mkOption {
        type = customTypes.transformer;
        readOnly = true;
        description = ''
          A transformer that adds the selected GTK accent color to schemes.
          Add this to `schemes.transformers` to make the accent color available
          in `schemes.scheme.accent` for use by other modules.
        '';
      };
    };

  config =
    let
      cfg = config.schemes.gtk;

      mkAccents =
        scheme:
        if cfg.overrides.accent == null then
          libScheme.gtk.mkAccentsFromPalette scheme.palette
        else
          libScheme.gtk.mkAccentsFromColor (cfg.overrides.accent libScheme);

      accents = mkAccents cfg.scheme;
    in
    lib.mkIf cfg.enable {
      schemes.gtk.accentTransformer = scheme: _: {
        accent = (mkAccents scheme).${cfg.accent};
      };

      gtk = {
        enable = lib.mkDefault true;

        colorScheme = cfg.scheme.variant;

        theme = {
          name = if cfg.scheme.variant == "light" then "adw-gtk3" else "adw-gtk3-dark";
          inherit (cfg.theme) package;
        };

        gtk3.extraCss = libScheme.gtk.adw-gtk3.mkGtk3ExtraCss {
          inherit (cfg) scheme accent;
          inherit accents;
        };

        gtk4.extraCss = libScheme.gtk.adw-gtk3.mkGtk4ExtraCss {
          inherit (cfg) scheme accent;
          inherit accents;
        };
      };

      dconf.settings."org/gnome/desktop/interface".accent-color = cfg.accent;
    };
}
