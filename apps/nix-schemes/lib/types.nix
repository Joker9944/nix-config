{ lib, ... }:
let
  inherit (lib) mkOption types literalExpression;
in
lib.fix (customTypes: {
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
        type = types.attrsOf customTypes.color;
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

  transformer = types.functionTo (types.functionTo types.attrs);
})
