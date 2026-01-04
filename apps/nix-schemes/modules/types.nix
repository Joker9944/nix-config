{ lib, ... }:
let
  inherit (lib) mkOption types literalExpression;
in
lib.fix (self: {
  scheme = types.submodule {
    freeformType = types.attrs;

    options = {
      system = mkOption {
        type = types.enum [
          "base16"
          "base24"
        ];
        description = ''
          The color scheme system.
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

      palette = mkOption {
        type = types.attrsOf self.color;
        description = ''
          The scheme color palette.
        '';
      };
    };
  };

  color = types.submodule {
    freeformType = types.attrs;

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
        example = "#007FFF";
        description = ''
          This formatted in hexadecimal color representation.
        '';
      };

      rgb = mkOption {
        type = types.str;
        example = "rgb(0,127,255)";
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

      mix = mkOption {
        type = types.functionTo (types.functionTo self.color);
        description = ''
          Function to mix this with another color with a weight.
        '';
      };

      adjust = mkOption {
        type = types.functionTo self.color;
        description = ''
          Function to scale this by a factor.
        '';
      };

      lighten = mkOption {
        type = types.functionTo self.color;
        description = ''
          Function to mix this with white with a weight.
        '';
      };

      darken = mkOption {
        type = types.functionTo self.color;
        description = ''
          FUnction to mix this with black with a weight.
        '';
      };
    };
  };

  transformer = types.functionTo (types.functionTo types.attrs);
})
