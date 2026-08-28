{ lib, ... }:
let
  inherit (lib) mkOption types literalExpression;
in
lib.fix (customTypes: {
  scheme = types.submodule {
    options = {
      meta = mkOption {
        type = types.submodule {
          options = {
            system = mkOption {
              type = types.enum [
                "base16"
                "base24"
              ];
              description = ''
                The color scheme system. Always `base24` — a base16 source is upcast on
                construction — and kept as provenance rather than as something to branch on.
              '';
            };

            name = mkOption {
              type = types.str;
              description = ''
                The scheme name.
              '';
            };

            author = mkOption {
              type = types.str;
              description = ''
                The author of the scheme.
              '';
            };

            variant = mkOption {
              type = types.enum [
                "light"
                "dark"
              ];
              description = ''
                The scheme shade system.
              '';
            };

            slug = mkOption {
              type = types.str;
              description = ''
                The scheme identifier, safe for file and theme names. Taken from the
                source where it carries one, otherwise derived from the name.
              '';
            };
          };
        };
        description = ''
          Where the scheme came from. Provenance only — nothing here is a color.
        '';
      };

      palette = mkOption {
        type = types.attrsOf customTypes.color;
        description = ''
          The scheme color palette, always the 24 base24 slots.
        '';
      };

      accent = mkOption {
        type = customTypes.color;
        description = ''
          The color consumers reach for when they need one that is not a background or a
          foreground.
        '';
      };

      named = mkOption {
        type = types.attrsOf (types.attrsOf customTypes.color);
        description = ''
          The palette under human-readable color words — `background.normal`,
          `red.bright` and the rest.
        '';
      };

      status = mkOption {
        type = types.attrsOf customTypes.color;
        description = ''
          The palette under the four UI status names — `info`, `warning`, `error`
          and `success`.
        '';
      };

      ansi = mkOption {
        type = types.attrsOf customTypes.color;
        description = ''
          The palette under the sixteen ANSI terminal colors, keyed `"0"` to `"F"`.
        '';
      };
    };
  };

  color = types.submodule {
    options = {
      dec = mkOption {
        type = types.listOf types.int;
        example = literalExpression "[ 0 127 255 ]";
        description = ''
          This formatted as rgb list of ints.
        '';
      };

      hex = mkOption {
        type = types.str;
        example = "007FFF";
        description = ''
          This formatted in hexadecimal color representation.
        '';
      };

      rgb = mkOption {
        type = types.str;
        example = "0,127,255";
        description = ''
          This formatted in decimal color representation.
        '';
      };

      rgba = mkOption {
        type = types.functionTo types.str;
        description = ''
          Function to format this in decimal color representation with an alpha channel.
        '';
      };

      xrgb = mkOption {
        type = types.str;
        example = "00/7F/FF";
        description = ''
          This formatted in xrgb representation.
        '';
      };

      mix = mkOption {
        type = types.functionTo (types.functionTo customTypes.color);
        description = ''
          Function to mix this with another color with a weight.
        '';
      };

      adjust = mkOption {
        type = types.functionTo customTypes.color;
        description = ''
          Function to scale this by a factor.
        '';
      };

      lighten = mkOption {
        type = types.functionTo customTypes.color;
        description = ''
          Function to mix this with white with a weight.
        '';
      };

      darken = mkOption {
        type = types.functionTo customTypes.color;
        description = ''
          Function to mix this with black with a weight.
        '';
      };

      rotateHue = mkOption {
        type = types.functionTo customTypes.color;
        description = ''
          Function to turn this around the color wheel by an angle in degrees.
        '';
      };

      red = mkOption {
        type = types.int;
        example = literalExpression "0";
        description = ''
          This red channel in decimal color representation.
        '';
      };

      green = mkOption {
        type = types.int;
        example = literalExpression "127";
        description = ''
          This green channel in decimal color representation.
        '';
      };

      blue = mkOption {
        type = types.int;
        example = literalExpression "255";
        description = ''
          This blue channel in decimal color representation.
        '';
      };
    };
  };
})
