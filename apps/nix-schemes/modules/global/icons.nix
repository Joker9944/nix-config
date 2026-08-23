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
  options.schemes.icons =
    let
      inherit (lib)
        literalExpression
        mkOption
        types
        ;
      customTypes = libSchemes.types;
    in
    {
      scheme = mkOption {
        type = types.nullOr customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme the icon pack is recolored against.
        '';
      };

      base = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = literalExpression "pkgs.colloid-icon-theme";
        description = ''
          Icon pack to recolor.
        '';
      };

      name = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "Colloid-Dark";
        description = ''
          Theme directory inside the pack that consumers should name. A pack ships several
          variants and the right one cannot be derived from `base`, so this moves with it.
        '';
      };

      package = mkOption {
        type = types.nullOr types.package;
        readOnly = true;
        description = ''
          The recolored pack. Null unless both a scheme and a pack are configured.
        '';
      };
    };

  config =
    let
      cfg = config.schemes.icons;
    in
    {
      schemes.icons.package =
        if cfg.scheme == null || cfg.base == null then
          null
        else
          libSchemes.mkIconTheme { inherit (cfg) scheme base; };
    };
}
