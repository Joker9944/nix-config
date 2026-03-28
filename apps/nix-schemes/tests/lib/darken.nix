{ libSchemes, ... }:
let
  gray = [
    128
    128
    128
  ];
  white = [
    255
    255
    255
  ];
in
{
  testDarkenZero = {
    expr = (libSchemes.darken gray 0).dec;
    expected = [
      128
      128
      128
    ];
  };

  testDarkenFull = {
    expr = (libSchemes.darken gray 1).dec;
    expected = [
      0
      0
      0
    ];
  };

  testDarkenHalf = {
    expr = (libSchemes.darken gray 0.5).dec;
    expected = [
      64
      64
      64
    ];
  };

  testDarkenWhite = {
    expr = (libSchemes.darken white 0.5).dec;
    expected = [
      128
      128
      128
    ];
  };

  testDarkenColorObject = {
    expr = (libSchemes.darken (libSchemes.mkColor gray) 0.5).dec;
    expected = [
      64
      64
      64
    ];
  };
}
