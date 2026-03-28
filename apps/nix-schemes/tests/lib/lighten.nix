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
    expr = (libSchemes.lighten gray 0).dec;
    expected = [
      128
      128
      128
    ];
  };

  testLightenFull = {
    expr = (libSchemes.lighten gray 1).dec;
    expected = [
      255
      255
      255
    ];
  };

  testLightenHalf = {
    expr = (libSchemes.lighten gray 0.5).dec;
    expected = [
      192
      192
      192
    ];
  };

  testLightenBlack = {
    expr = (libSchemes.lighten black 0.5).dec;
    expected = [
      128
      128
      128
    ];
  };

  testLightenColorObject = {
    expr = (libSchemes.lighten (libSchemes.mkColor gray) 0.5).dec;
    expected = [
      192
      192
      192
    ];
  };
}
