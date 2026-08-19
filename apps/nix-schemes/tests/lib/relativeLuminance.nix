{ libSchemes, ... }:
{
  testBlack = {
    expr = libSchemes.color.relativeLuminance [
      0
      0
      0
    ];
    expected = 0.0;
  };

  # Not exactly 1: nix-math derives `pow` from exp/ln, so the transfer curve
  # round-trips to within ~1e-15.
  testWhite = {
    expr = libSchemes.color.relativeLuminance [
      255
      255
      255
    ];
    expected = 0.9999999999999996;
  };

  testLinearizesBeforeWeighting = {
    expr = libSchemes.color.relativeLuminance [
      217
      83
      107
    ];
    expected = 0.2199976355156877;
  };
}
