{ libSchemes, ... }:
{
  testClampWithinRange = {
    expr = libSchemes.clamp 0 255 128;
    expected = 128;
  };

  testClampAtMin = {
    expr = libSchemes.clamp 0 255 0;
    expected = 0;
  };

  testClampAtMax = {
    expr = libSchemes.clamp 0 255 255;
    expected = 255;
  };

  testClampBelowMin = {
    expr = libSchemes.clamp 0 255 (-10);
    expected = 0;
  };

  testClampAboveMax = {
    expr = libSchemes.clamp 0 255 300;
    expected = 255;
  };

  testClampCustomRange = {
    expr = libSchemes.clamp 10 20 15;
    expected = 15;
  };

  testClampCustomRangeBelowMin = {
    expr = libSchemes.clamp 10 20 5;
    expected = 10;
  };

  testClampCustomRangeAboveMax = {
    expr = libSchemes.clamp 10 20 25;
    expected = 20;
  };
}
