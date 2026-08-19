{ libSchemes, ... }:
{
  testExtremes = {
    expr = libSchemes.color.contrastRatio [ 0 0 0 ] [ 255 255 255 ];
    expected = 20.99999999999999;
  };

  testIdentical = {
    expr = libSchemes.color.contrastRatio [ 100 100 100 ] [ 100 100 100 ];
    expected = 1.0;
  };

  testOrderIndependent = {
    expr = libSchemes.color.contrastRatio [ 28 20 40 ] [ 217 83 107 ];
    expected = 4.575929158145937;
  };

  testAcceptsColor = {
    expr =
      libSchemes.color.contrastRatio
        (libSchemes.mkColor [
          217
          83
          107
        ])
        (
          libSchemes.mkColor [
            233
            221
            242
          ]
        );
    expected = 2.979557421326366;
  };
}
