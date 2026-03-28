{ libSchemes, ... }:
{
  testIsColorWithColorObject = {
    expr = libSchemes.isColor (
      libSchemes.mkColor [
        255
        0
        0
      ]
    );
    expected = true;
  };

  testIsColorWithDecList = {
    expr = libSchemes.isColor [
      255
      0
      0
    ];
    expected = false;
  };

  testIsColorWithString = {
    expr = libSchemes.isColor "#FF0000";
    expected = false;
  };

  testIsColorWithEmptyAttrs = {
    expr = libSchemes.isColor { };
    expected = false;
  };

  testIsColorWithWrongAttr = {
    expr = libSchemes.isColor { rgb = "rgb(0,0,0)"; };
    expected = false;
  };

  testIsColorWithDecAttr = {
    expr = libSchemes.isColor {
      dec = [
        0
        0
        0
      ];
    };
    expected = true;
  };

  testIsColorWithWrongLength = {
    expr = libSchemes.isColor {
      dec = [
        0
        0
      ];
    };
    expected = false;
  };

  testIsColorWithDecNotList = {
    expr = libSchemes.isColor { dec = "not a list"; };
    expected = false;
  };
}
