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
  options.schemes.regreet =
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
      cfg = config.schemes.regreet;

      accents = libSchemes.gtk.mkAccents {
        inherit (cfg) scheme;
        inherit (cfg.accents) mode;
      };

      themeCss = libSchemes.mkGtkThemeCss {
        inherit (cfg) scheme accent;
        inherit accents;
      };
    in
    lib.mkIf cfg.enable {
      programs.regreet = {
        enable = lib.mkDefault true;

        theme = {
          name = if cfg.scheme.meta.variant == "light" then "adw-gtk3" else "adw-gtk3-dark";
          inherit (cfg.theme) package;
        };

        extraCss = lib.mkBefore "@import \"${themeCss}/gtk4.css\";";
      };
    };
}
