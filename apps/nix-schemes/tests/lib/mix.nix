{ libSchemes, ... }:
let
  red = [
    255
    0
    0
  ];
  blue = [
    0
    0
    255
  ];
  white = [
    255
    255
    255
  ];
  black = [
    0
    0
    0
  ];
in
{
  # Weight 0 = 100% first color
  testMixZeroWeight = {
    expr = (libSchemes.mix red blue 0).dec;
    expected = [
      255
      0
      0
    ];
  };

  # Weight 1 = 100% second color
  testMixFullWeight = {
    expr = (libSchemes.mix red blue 1).dec;
    expected = [
      0
      0
      255
    ];
  };

  # Weight 0.5 = 50/50 mix
  testMixHalfWeight = {
    expr = (libSchemes.mix red blue 0.5).dec;
    expected = [
      128
      0
      128
    ];
  };

  # Mix with white (lighten)
  testMixWithWhite = {
    expr = (libSchemes.mix black white 0.5).dec;
    expected = [
      128
      128
      128
    ];
  };

  # Mix with black (darken)
  testMixWithBlack = {
    expr = (libSchemes.mix white black 0.5).dec;
    expected = [
      128
      128
      128
    ];
  };

  # Mix using color objects
  testMixColorObjects = {
    expr = (libSchemes.mix (libSchemes.mkColor red) (libSchemes.mkColor blue) 0.5).dec;
    expected = [
      128
      0
      128
    ];
  };
}
