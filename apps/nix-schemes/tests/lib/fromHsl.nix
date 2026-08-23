{ libSchemes, ... }:
{
  testFromHslRed = {
    expr =
      (libSchemes.color.fromHsl {
        h = 0;
        s = 1;
        l = 0.5;
      }).dec;
    expected = [
      255
      0
      0
    ];
  };

  testFromHslGreen = {
    expr =
      (libSchemes.color.fromHsl {
        h = 120;
        s = 1;
        l = 0.5;
      }).dec;
    expected = [
      0
      255
      0
    ];
  };

  testFromHslBlue = {
    expr =
      (libSchemes.color.fromHsl {
        h = 240;
        s = 1;
        l = 0.5;
      }).dec;
    expected = [
      0
      0
      255
    ];
  };

  testFromHslUnsaturated = {
    expr =
      (libSchemes.color.fromHsl {
        h = 0;
        s = 0;
        l = 0.5;
      }).dec;
    expected = [
      128
      128
      128
    ];
  };

  testFromHslRoundTrip = {
    expr =
      (libSchemes.color.fromHsl (
        libSchemes.color.toHsl [
          200
          110
          208
        ]
      )).dec;
    expected = [
      200
      110
      208
    ];
  };
}
