{ libSchemes, ... }:
{
  testToHexBlack = {
    expr = libSchemes.color.toHex [
      0
      0
      0
    ];
    expected = "000000";
  };

  testToHexWhite = {
    expr = libSchemes.color.toHex [
      255
      255
      255
    ];
    expected = "FFFFFF";
  };

  testToHexRed = {
    expr = libSchemes.color.toHex [
      255
      0
      0
    ];
    expected = "FF0000";
  };

  testToHexGreen = {
    expr = libSchemes.color.toHex [
      0
      255
      0
    ];
    expected = "00FF00";
  };

  testToHexBlue = {
    expr = libSchemes.color.toHex [
      0
      0
      255
    ];
    expected = "0000FF";
  };

  testToHexMixed = {
    expr = libSchemes.color.toHex [
      26
      43
      60
    ];
    expected = "1A2B3C";
  };

  testToHexSingleDigit = {
    expr = libSchemes.color.toHex [
      1
      2
      3
    ];
    expected = "010203";
  };
}
