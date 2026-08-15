{ libSchemes, ... }:
let
  scheme = libSchemes.mkScheme {
    system = "base16";
    name = "Test";
    author = "nobody";
    variant = "dark";
    palette.base00 = libSchemes.mkColor [
      255
      85
      0
    ];
  };
in
{
  testToSpecKeepsMetadata = {
    expr = (libSchemes.toSpec scheme).name;
    expected = "Test";
  };

  testToSpecFlattensColor = {
    expr = (libSchemes.toSpec scheme).palette.base00;
    expected = {
      hex = "FF5500";
      rgb = "255,85,0";
      dec = [
        255
        85
        0
      ];
    };
  };

  # `transform` on the scheme and `mix`/`adjust`/… on each color must not survive,
  # or the result cannot be serialized.
  testToSpecDropsFunctions = {
    expr = builtins.fromJSON (builtins.toJSON (libSchemes.toSpec scheme)) == libSchemes.toSpec scheme;
    expected = true;
  };
}
