{ libSchemes, ... }:
{
  testPositive = {
    expr = libSchemes.util.calcColorRatios [ 125 125 125 ] [ 200 200 200 ];
    expected = [
      0.29411764705882354
      0.29411764705882354
      0.29411764705882354
    ];
  };

  testNegative = {
    expr = libSchemes.util.calcColorRatios [ 200 200 200 ] [ 125 125 125 ];
    expected = [
      (-0.29411764705882354)
      (-0.29411764705882354)
      (-0.29411764705882354)
    ];
  };
}
