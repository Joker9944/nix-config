{ libSchemes, ... }:
let
  red = [
    255
    0
    0
  ];
in
{
  testRotateHueThird = {
    expr = (libSchemes.color.rotateHue red 120).dec;
    expected = [
      0
      255
      0
    ];
  };

  testRotateHueBackwards = {
    expr = (libSchemes.color.rotateHue red (-120)).dec;
    expected = [
      0
      0
      255
    ];
  };

  testRotateHueFullTurn = {
    expr = (libSchemes.color.rotateHue red 360).dec;
    expected = red;
  };

  # Past a full turn is the same as within one
  testRotateHueWraps = {
    expr = (libSchemes.color.rotateHue red 480).dec;
    expected = (libSchemes.color.rotateHue red 120).dec;
  };

  # Nothing to turn on an achromatic color
  testRotateHueGray = {
    expr =
      (libSchemes.color.rotateHue [
        128
        128
        128
      ] 90).dec;
    expected = [
      128
      128
      128
    ];
  };

  testRotateHueColorObject = {
    expr = (libSchemes.color.rotateHue (libSchemes.color.mkColor red) 120).dec;
    expected = [
      0
      255
      0
    ];
  };

  testRotateHueFractionalAngle = {
    expr =
      (libSchemes.color.rotateHue [
        217
        83
        107
      ] 47.5).dec;
    expected = [
      217
      165
      83
    ];
  };

  testRotateHueFractionalBackwards = {
    expr =
      (libSchemes.color.rotateHue [
        61
        148
        97
      ] (-317.3)).dec;
    expected = [
      61
      137
      148
    ];
  };
}
