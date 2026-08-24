{ libSchemes, ... }:
{
  testToHslRed = {
    expr = libSchemes.color.toHsl [
      255
      0
      0
    ];
    expected = {
      h = 0;
      s = 1;
      l = 0.5;
    };
  };

  testToHslGreen = {
    expr = libSchemes.color.toHsl [
      0
      255
      0
    ];
    expected = {
      h = 120;
      s = 1;
      l = 0.5;
    };
  };

  testToHslBlue = {
    expr = libSchemes.color.toHsl [
      0
      0
      255
    ];
    expected = {
      h = 240;
      s = 1;
      l = 0.5;
    };
  };

  testToHslBlack = {
    expr = libSchemes.color.toHsl [
      0
      0
      0
    ];
    expected = {
      h = 0;
      s = 0;
      l = 0;
    };
  };

  testToHslWhite = {
    expr = libSchemes.color.toHsl [
      255
      255
      255
    ];
    expected = {
      h = 0;
      s = 0;
      l = 1;
    };
  };

  # Achromatic has no hue to report
  testToHslGrayHasNoHue = {
    expr =
      (libSchemes.color.toHsl [
        128
        128
        128
      ]).s;
    expected = 0;
  };

  # Red past the seam at 0 comes out of the sextant negative and must wrap up
  testToHslWrapsBelowSeam = {
    expr =
      (libSchemes.color.toHsl [
        255
        0
        128
      ]).h > 180;
    expected = true;
  };

  testToHslColorObject = {
    expr = libSchemes.color.toHsl (
      libSchemes.color.mkColor [
        255
        0
        0
      ]
    );
    expected = {
      h = 0;
      s = 1;
      l = 0.5;
    };
  };

  # Off-axis colors, one per sextant branch. Red-max with `b > g` is the branch
  # that wraps past the seam.
  testToHslRedMax = {
    expr = libSchemes.color.toHsl [
      217
      83
      107
    ];
    expected = {
      h = 349.25373134328356;
      s = 0.638095238095238;
      l = 0.5882352941176471;
    };
  };

  testToHslGreenMax = {
    expr = libSchemes.color.toHsl [
      61
      148
      97
    ];
    expected = {
      h = 144.82758620689654;
      s = 0.416267942583732;
      l = 0.4098039215686275;
    };
  };

  testToHslBlueMax = {
    expr = libSchemes.color.toHsl [
      44
      66
      189
    ];
    expected = {
      h = 230.89655172413794;
      s = 0.6223175965665235;
      l = 0.45686274509803926;
    };
  };

  # One channel off near-black: chroma is tiny but the divisor stays sane
  testToHslNearBlack = {
    expr = libSchemes.color.toHsl [
      3
      3
      4
    ];
    expected = {
      h = 240.0;
      s = 0.1428571428571428;
      l = 0.013725490196078431;
    };
  };
}
