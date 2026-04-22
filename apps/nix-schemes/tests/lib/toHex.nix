{ libSchemes, ... }:
{
  testToHexBlack = {
    expr = libSchemes.toHex [
      0
      0
      0
    ];
    expected = "000000";
  };

  testToHexWhite = {
    expr = libSchemes.toHex [
      255
      255
      255
    ];
    expected = "FFFFFF";
  };

  testToHexRed = {
    expr = libSchemes.toHex [
      255
      0
      0
    ];
    expected = "FF0000";
  };

  testToHexGreen = {
    expr = libSchemes.toHex [
      0
      255
      0
    ];
    expected = "00FF00";
  };

  testToHexBlue = {
    expr = libSchemes.toHex [
      0
      0
      255
    ];
    expected = "0000FF";
  };

  testToHexMixed = {
    expr = libSchemes.toHex [
      26
      43
      60
    ];
    expected = "1A2B3C";
  };

  testToHexSingleDigit = {
    expr = libSchemes.toHex [
      1
      2
      3
    ];
    expected = "010203";
  };
}
