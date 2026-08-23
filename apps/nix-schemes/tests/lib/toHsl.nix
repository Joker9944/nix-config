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
}
