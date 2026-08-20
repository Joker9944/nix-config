{ libSchemes, ... }:
{
  testFromHexBlack = {
    expr = libSchemes.color.fromHex "#000000";
    expected = [
      0
      0
      0
    ];
  };

  testFromHexWhite = {
    expr = libSchemes.color.fromHex "#FFFFFF";
    expected = [
      255
      255
      255
    ];
  };

  testFromHexRed = {
    expr = libSchemes.color.fromHex "#FF0000";
    expected = [
      255
      0
      0
    ];
  };

  testFromHexGreen = {
    expr = libSchemes.color.fromHex "#00FF00";
    expected = [
      0
      255
      0
    ];
  };

  testFromHexBlue = {
    expr = libSchemes.color.fromHex "#0000FF";
    expected = [
      0
      0
      255
    ];
  };

  testFromHexMixed = {
    expr = libSchemes.color.fromHex "#1A2B3C";
    expected = [
      26
      43
      60
    ];
  };

  testFromHexLowercase = {
    expr = libSchemes.color.fromHex "#abcdef";
    expected = [
      171
      205
      239
    ];
  };

  testFromHexWithoutHash = {
    expr = libSchemes.color.fromHex "AABBCC"; # cSpell:ignore AABBCC
    expected = [
      170
      187
      204
    ];
  };
}
