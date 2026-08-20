{ libSchemes, ... }:
let
  gray = [
    128
    128
    128
  ];
in
{
  testAdjustNoChange = {
    expr = (libSchemes.color.adjust gray 1).dec;
    expected = [
      128
      128
      128
    ];
  };

  testAdjustDouble = {
    expr = (libSchemes.color.adjust gray 2).dec;
    expected = [
      255
      255
      255
    ];
  };

  testAdjustHalf = {
    expr = (libSchemes.color.adjust gray 0.5).dec;
    expected = [
      64
      64
      64
    ];
  };

  testAdjustZero = {
    expr = (libSchemes.color.adjust gray 0).dec;
    expected = [
      0
      0
      0
    ];
  };

  testAdjustClampsMax = {
    expr = (libSchemes.color.adjust [ 200 200 200 ] 2).dec;
    expected = [
      255
      255
      255
    ];
  };

  testAdjustColorObject = {
    expr = (libSchemes.color.adjust (libSchemes.color.mkColor gray) 0.5).dec;
    expected = [
      64
      64
      64
    ];
  };
}
