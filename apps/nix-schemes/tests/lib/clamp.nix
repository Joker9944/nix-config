{ libSchemes, ... }:
{
  testClampWithinRange = {
    expr = libSchemes.util.clamp 0 255 128;
    expected = 128;
  };

  testClampAtMin = {
    expr = libSchemes.util.clamp 0 255 0;
    expected = 0;
  };

  testClampAtMax = {
    expr = libSchemes.util.clamp 0 255 255;
    expected = 255;
  };

  testClampBelowMin = {
    expr = libSchemes.util.clamp 0 255 (-10);
    expected = 0;
  };

  testClampAboveMax = {
    expr = libSchemes.util.clamp 0 255 300;
    expected = 255;
  };

  testClampCustomRange = {
    expr = libSchemes.util.clamp 10 20 15;
    expected = 15;
  };

  testClampCustomRangeBelowMin = {
    expr = libSchemes.util.clamp 10 20 5;
    expected = 10;
  };

  testClampCustomRangeAboveMax = {
    expr = libSchemes.util.clamp 10 20 25;
    expected = 20;
  };
}
