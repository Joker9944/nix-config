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
  options.schemes.cursors =
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
          Color scheme the cursor theme is compiled against.
        '';
      };

      slots = mkOption {
        type = types.attrsOf customTypes.color;
        default = { };
        example = literalExpression "{ accentAlt = libSchemes.color.mkColor [ 0 127 255 ]; }";
        description = ''
          Colors overriding the defaults derived from the scheme. The slots are `fill`,
          `outline`, `shadow`, `accent`, `accentAlt`, `negative`, `positive`, `info` and
          `neutral`.
        '';
      };

      name = mkOption {
        type = types.nullOr types.str;
        readOnly = true;
        description = ''
          Theme directory consumers should name. Derived, unlike `schemes.icons.name` —
          the theme is compiled here rather than picked out of a pack.
        '';
      };

      package = mkOption {
        type = types.nullOr types.package;
        readOnly = true;
        description = ''
          The compiled theme, carrying XCursor, `cursors_scalable` and hyprcursor. Null
          unless a scheme is configured.
        '';
      };
    };

  config =
    let
      cfg = config.schemes.cursors;

      package =
        if cfg.scheme == null then null else libSchemes.mkCursorTheme { inherit (cfg) scheme slots; };
    in
    {
      schemes.cursors = {
        inherit package;

        name = if package == null then null else package.themeName;
      };
    };
}
