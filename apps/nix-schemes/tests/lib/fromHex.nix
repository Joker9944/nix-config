{ libSchemes, ... }:
{
  testFromHexBlack = {
    expr = libSchemes.fromHex "#000000";
    expected = [
      0
      0
      0
    ];
  };

  testFromHexWhite = {
    expr = libSchemes.fromHex "#FFFFFF";
    expected = [
      255
      255
      255
    ];
  };

  testFromHexRed = {
    expr = libSchemes.fromHex "#FF0000";
    expected = [
      255
      0
      0
    ];
  };

  testFromHexGreen = {
    expr = libSchemes.fromHex "#00FF00";
    expected = [
      0
      255
      0
    ];
  };

  testFromHexBlue = {
    expr = libSchemes.fromHex "#0000FF";
    expected = [
      0
      0
      255
    ];
  };

  testFromHexMixed = {
    expr = libSchemes.fromHex "#1A2B3C";
    expected = [
      26
      43
      60
    ];
  };

  testFromHexLowercase = {
    expr = libSchemes.fromHex "#abcdef";
    expected = [
      171
      205
      239
    ];
  };

  testFromHexWithoutHash = {
    expr = libSchemes.fromHex "AABBCC"; # cSpell:ignore AABBCC
    expected = [
      170
      187
      204
    ];
  };
}
