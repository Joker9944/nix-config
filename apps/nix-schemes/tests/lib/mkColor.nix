{ libSchemes, ... }:
let
  red = libSchemes.mkColor [
    255
    0
    0
  ];
  white = libSchemes.mkColor [
    255
    255
    255
  ];
  black = libSchemes.mkColor [
    0
    0
    0
  ];
in
{
  testMkColorDec = {
    expr = red.dec;
    expected = [
      255
      0
      0
    ];
  };

  testMkColorHex = {
    expr = red.hex;
    expected = "FF0000";
  };

  testMkColorRgb = {
    expr = red.rgb;
    expected = "255,0,0";
  };

  testMkColorRgba = {
    expr = red.rgba 0.5;
    expected = "255,0,0,0.5";
  };

  testMkColorIsColor = {
    expr = libSchemes.isColor red;
    expected = true;
  };

  testMkColorWhiteHex = {
    expr = white.hex;
    expected = "FFFFFF";
  };

  testMkColorBlackHex = {
    expr = black.hex;
    expected = "000000";
  };
}
