{ libUtil, ... }:
{
  testClampWithinRange = {
    expr = libUtil.numbers.clamp 0 255 128;
    expected = 128;
  };

  testClampAtMin = {
    expr = libUtil.numbers.clamp 0 255 0;
    expected = 0;
  };

  testClampAtMax = {
    expr = libUtil.numbers.clamp 0 255 255;
    expected = 255;
  };

  testClampBelowMin = {
    expr = libUtil.numbers.clamp 0 255 (-10);
    expected = 0;
  };

  testClampAboveMax = {
    expr = libUtil.numbers.clamp 0 255 300;
    expected = 255;
  };

  testClampCustomRange = {
    expr = libUtil.numbers.clamp 10 20 15;
    expected = 15;
  };

  testClampCustomRangeBelowMin = {
    expr = libUtil.numbers.clamp 10 20 5;
    expected = 10;
  };

  testClampCustomRangeAboveMax = {
    expr = libUtil.numbers.clamp 10 20 25;
    expected = 20;
  };
}
