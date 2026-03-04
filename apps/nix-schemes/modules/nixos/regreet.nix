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
  options.schemes.regreet =
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
      enable = mkEnableOption "ReGreet theming based on adw-gtk3 and a scheme";

      theme.package = mkPackageOption pkgs "adw-gtk3" { };

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to customize the adw-gtk3 theme.
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
    };

  config =
    let
      cfg = config.schemes.regreet;

      accents =
        if cfg.overrides.accent == null then
          libScheme.gtk.mkAccentsFromPalette cfg.scheme.palette
        else
          libScheme.gtk.mkAccentsFromColor (cfg.overrides.accent libScheme);
    in
    lib.mkIf cfg.enable {
      programs.regreet = {
        enable = lib.mkDefault true;

        theme = {
          name = if cfg.scheme.variant == "light" then "adw-gtk3" else "adw-gtk3-dark";
          inherit (cfg.theme) package;
        };

        extraCss = libScheme.gtk.adw-gtk3.mkGtk4ExtraCss {
          inherit (cfg) scheme accent;
          inherit accents;
        };
      };
    };
}
