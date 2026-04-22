{ libSchemes, ... }:
{
  testToRgbBlack = {
    expr = libSchemes.toRgb [
      0
      0
      0
    ];
    expected = "0,0,0";
  };

  testToRgbWhite = {
    expr = libSchemes.toRgb [
      255
      255
      255
    ];
    expected = "255,255,255";
  };

  testToRgbMixed = {
    expr = libSchemes.toRgb [
      128
      64
      32
    ];
    expected = "128,64,32";
  };
}
