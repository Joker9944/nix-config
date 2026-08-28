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

      accents.mode = mkOption {
        type = types.enum [
          "palette"
          "uniform"
        ];
        default = "palette";
        description = ''
          Where the nine accent colors come from: `palette` spreads the scheme palette
          across them, `uniform` collapses them onto `schemes.scheme.accent`.
        '';
      };
    };

  config =
    let
      cfg = config.schemes.gtk;

      accents = libSchemes.gtk.mkAccents {
        inherit (cfg) scheme;
        inherit (cfg.accents) mode;
      };

      themeName = if cfg.scheme.meta.variant == "light" then "adw-gtk3" else "adw-gtk3-dark";

      themeCss = libSchemes.mkGtkThemeCss {
        inherit (cfg) scheme accent;
        inherit accents;
      };
    in
    lib.mkIf cfg.enable {
      gtk = {
        enable = lib.mkDefault true;

        colorScheme = cfg.scheme.meta.variant;

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
