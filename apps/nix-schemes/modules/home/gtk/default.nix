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
  accentNames = [
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
      customTypes = flake.lib.types;
    in
    {
      enable = mkEnableOption "GTK theming based on adw-gtk3 and a scheme";

      theme.package = mkPackageOption pkgs "adw-gtk3" { };

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to theme GTK theme.
        '';
      };

      accent = mkOption {
        type = types.enum accentNames;
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

        '';
      };
    };

  config =
    let
      cfg = config.schemes.gtk;

      mkAccents =
        scheme:
        let
          inherit (scheme) palette;
        in
        if cfg.overrides.accent == null then
          {
            blue = palette.base0D;
            teal = palette.base0C;
            green = palette.base0B;
            yellow = palette.base09;
            orange = palette.base08.mix palette.base09 0.5; # red yellow 50% mix
            red = palette.base08;
            pink = palette.base08.lighten 0.33; # red white 33% mix
            purple = palette.base0E;
            slate = palette.base03;
          }
        else
          lib.pipe accentNames [
            (lib.map (name: {
              inherit name;
              value = cfg.overrides.accent (flake.lib.init pkgs);
            }))
            lib.listToAttrs
          ];

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

        gtk3.extraCss = lib.concatStrings [
          (import ./templates/gtk3-base.css.nix cfg accents)
          (lib.optionalString (cfg.scheme.variant == "dark") (import ./templates/gtk3-dark.css.nix))
        ];

        gtk4.extraCss = import ./templates/gtk4.css.nix cfg accents;
      };

      dconf.settings."org/gnome/desktop/interface".accent-color = cfg.accent;
    };
}
