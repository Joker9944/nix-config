# https://github.com/lassekongo83/adw-gtk3
# https://github.com/lassekongo83/adw-colors
_:
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
        ;
    in
    {
      enable = mkEnableOption "GTK tinting based on adw-gtk3 and a scheme";

      theme = {
        package = mkPackageOption pkgs "adw-gtk3" { };
      };

      scheme = mkOption {
        type = types.submodule {
          freeformType = types.attrs;

          options = {
            variant = mkOption {
              type = types.enum [
                "light"
                "dark"
              ];
              description = ''
                The scheme variant. Should be set on imported schemes.
              '';
            };
          };
        };
        default = { };
        description = ''
          A color scheme
        '';
      };

      accent = mkOption {
        type = types.enum accentNames;
        default = "purple";
        description = ''
          The GTK accent color based on the GTK 4 accent system.
        '';
      };

      accentOverride = mkOption {
        type = types.nullOr types.attrs;
        default = null;
      };

      accentColor = mkOption {
        type = types.attrs;
        readOnly = true;
        description = ''
          The selected accent color.
        '';
      };
    };

  config =
    let
      cfg = config.schemes.gtk;
      inherit (cfg.scheme) palette;

      accents =
        if cfg.accentOverride == null then
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
              value = cfg.accentOverride;
            }))
            lib.listToAttrs
          ];
    in
    lib.mkIf cfg.enable {
      schemes.gtk.accentColor = accents.${cfg.accent};

      gtk = {
        enable = lib.mkDefault true;

        colorScheme = cfg.scheme.variant;

        theme = {
          name = if cfg.scheme.variant == "light" then "adw-gtk3" else "adw-gtk3-dark";
          inherit (cfg.theme) package;
        };

        gtk3.extraCss = lib.concatStrings [
          (import ./css/gtk3-base.css.nix cfg accents)
          (lib.optionalString (cfg.scheme.variant == "dark") (import ./css/gtk3-dark.css.nix))
        ];

        gtk4.extraCss = import ./css/gtk4.css.nix cfg accents;
      };

      dconf.settings."org/gnome/desktop/interface".accent-color = cfg.accent;
    };
}
