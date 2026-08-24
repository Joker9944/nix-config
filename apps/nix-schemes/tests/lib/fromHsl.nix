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

  testFromHslOffBoundaryHue = {
    expr =
      (libSchemes.color.fromHsl {
        h = 37.4;
        s = 0.63;
        l = 0.29;
      }).dec;
    expected = [
      121
      85
      27
    ];
  };

  # Just below the seam, where the ramp offset hits 12 and has to wrap
  testFromHslBelowSeam = {
    expr =
      (libSchemes.color.fromHsl {
        h = 359.9;
        s = 0.42;
        l = 0.71;
      }).dec;
    expected = [
      212
      150
      150
    ];
  };

  # Barely saturated: the channels have to survive rounding apart
  testFromHslNearGray = {
    expr =
      (libSchemes.color.fromHsl {
        h = 200.5;
        s = 0.015;
        l = 0.502;
      }).dec;
    expected = [
      126
      129
      130
    ];
  };

  testFromHslRoundTripOffAxis = {
    expr =
      (libSchemes.color.fromHsl (
        libSchemes.color.toHsl [
          217
          83
          107
        ]
      )).dec;
    expected = [
      217
      83
      107
    ];
  };

  testFromHslRoundTripNearBlack = {
    expr =
      (libSchemes.color.fromHsl (
        libSchemes.color.toHsl [
          3
          3
          4
        ]
      )).dec;
    expected = [
      3
      3
      4
    ];
  };
}
