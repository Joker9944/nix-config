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
      inherit (lib) mkOption types;
      customTypes = libSchemes.types;

      cfg = config.schemes.cursors;
      inherit (cfg.scheme) palette;

      mkColorOption =
        default: slot:
        mkOption {
          inherit default;
          type = customTypes.color;
          description = ''
            Color of the ${slot} paint slot.
          '';
        };
    in
    {
      scheme = mkOption {
        type = types.nullOr customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme the cursor theme is compiled against.
        '';
      };

      # The cursor is drawn as a body inside an outline, so the two take opposite ends of
      # the palette and swap with the variant — that is the whole of what Breeze_Light
      # would add. The rest are Breeze's own semantics, which already line up with base24
      # slots.
      colors = {
        fill = mkColorOption (
          if cfg.scheme.meta.variant == "dark" then palette.base00 else palette.base06
        ) "cursor body";
        outline = mkColorOption (
          if cfg.scheme.meta.variant == "dark" then palette.base06 else palette.base00
        ) "cursor outline";

        # Drawn under a blur at 20% opacity, where a palette color reads as dirt.
        shadow = mkColorOption (libSchemes.color.mkColor [
          0
          0
          0
        ]) "drop shadow";

        accent = mkColorOption cfg.scheme.accent "accented shapes";

        # Breeze pairs its accent with a second hue a long way round the wheel rather than
        # opposite it — 154°, not 180°. A triad turn is the same idea and lands on teal for
        # the purple accents here, which is Breeze's own accent hue with the roles swapped.
        accentAlt = mkColorOption (cfg.scheme.accent.rotateHue (-120)) "second accent";

        negative = mkColorOption palette.base08 "no-drop and forbidden";
        positive = mkColorOption palette.base0B "copy and link";
        info = mkColorOption palette.base0D "help";
        neutral = mkColorOption palette.base09 "progress";
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
        if cfg.scheme == null then null else libSchemes.mkCursorTheme { inherit (cfg) scheme colors; };
    in
    {
      schemes.cursors = {
        inherit package;

        name = if package == null then null else package.themeName;
      };
    };
}
