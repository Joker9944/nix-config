{ libSchemes, ... }:
let
  gray = [
    128
    128
    128
  ];
  black = [
    0
    0
    0
  ];
in
{
  testLightenZero = {
    expr = (libSchemes.color.lighten gray 0).dec;
    expected = [
      128
      128
      128
    ];
  };

  testLightenFull = {
    expr = (libSchemes.color.lighten gray 1).dec;
    expected = [
      255
      255
      255
    ];
  };

  testLightenHalf = {
    expr = (libSchemes.color.lighten gray 0.5).dec;
    expected = [
      192
      192
      192
    ];
  };

  testLightenBlack = {
    expr = (libSchemes.color.lighten black 0.5).dec;
    expected = [
      128
      128
      128
    ];
  };

  testLightenColorObject = {
    expr = (libSchemes.color.lighten (libSchemes.color.mkColor gray) 0.5).dec;
    expected = [
      192
      192
      192
    ];
  };
}
