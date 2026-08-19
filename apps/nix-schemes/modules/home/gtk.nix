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
  libSchemes = flake.lib.libSchemes.init pkgs;
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
      customTypes = libSchemes.types;
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
        example = literalExpression "libSchemes: libSchemes.mkColor [ 0 127 255 ]";
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
          libSchemes.gtk.mkAccentsFromPalette scheme.palette
        else
          libSchemes.gtk.mkAccentsFromColor (cfg.overrides.accent libSchemes);

      accents = mkAccents cfg.scheme;

      themeName = if cfg.scheme.variant == "light" then "adw-gtk3" else "adw-gtk3-dark";

      themeCss = libSchemes.mkThemeCss {
        inherit (cfg) scheme accent;
        inherit accents;
      };
    in
    lib.mkIf cfg.enable {
      schemes.gtk.accentTransformer = scheme: _: {
        accent = (mkAccents scheme).${cfg.accent};
      };

      gtk = {
        enable = lib.mkDefault true;

        colorScheme = cfg.scheme.variant;

        theme = {
          name = themeName;
          inherit (cfg.theme) package;
        };

        gtk3.extraCss = lib.mkBefore "@import \"${themeCss}/gtk3.css\";";

        gtk4 = {
          # The adw-gtk3 theme is for gtk3 and gtk4 apps, NOT libadwaita apps.
          # With the theme setting hm forces ALL apps to take the theme.
          # Setting `gtk-theme-name` only for gtk3 and gtk4 apps.
          theme = null;
          # WORKAROUND Home-manager only emits `gtk-theme-name` when `gtk4.theme` is set
          extraConfig.gtk-theme-name = themeName;

          extraCss = lib.mkBefore "@import \"${themeCss}/gtk4.css\";";
        };
      };

      dconf.settings."org/gnome/desktop/interface".accent-color = cfg.accent;
    };
}
