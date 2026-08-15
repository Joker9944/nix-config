{ libUtil, ... }:
{
  testToStringFloatKeepsFraction = {
    expr = libUtil.numbers.toStringFloat 0.5;
    expected = "0.5";
  };

  testToStringFloatDropsWholeFraction = {
    expr = libUtil.numbers.toStringFloat 1.0;
    expected = "1";
  };

  testToStringFloatZero = {
    expr = libUtil.numbers.toStringFloat 0.0;
    expected = "0";
  };

  # The decimal point stops the strip, so zeros in the integer part survive.
  testToStringFloatKeepsIntegerZeros = {
    expr = libUtil.numbers.toStringFloat 100.0;
    expected = "100";
  };

  testToStringFloatMixed = {
    expr = libUtil.numbers.toStringFloat 10.5;
    expected = "10.5";
  };

  testToStringFloatNoTrailingZeros = {
    expr = libUtil.numbers.toStringFloat 0.125;
    expected = "0.125";
  };

  testToStringFloatNegative = {
    expr = libUtil.numbers.toStringFloat (-2.5);
    expected = "-2.5";
  };

  # Integers never reach the strip — `toString` gives them no decimal point.
  testToStringFloatIntegerTrailingZeros = {
    expr = libUtil.numbers.toStringFloat 100;
    expected = "100";
  };

  testToStringFloatInteger = {
    expr = libUtil.numbers.toStringFloat 3;
    expected = "3";
  };
}
