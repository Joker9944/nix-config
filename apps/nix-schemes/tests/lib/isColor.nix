{ libSchemes, ... }:
{
  testIsColorWithColorObject = {
    expr = libSchemes.color.isColor (
      libSchemes.color.mkColor [
        255
        0
        0
      ]
    );
    expected = true;
  };

  testIsColorWithDecList = {
    expr = libSchemes.color.isColor [
      255
      0
      0
    ];
    expected = false;
  };

  testIsColorWithString = {
    expr = libSchemes.color.isColor "#FF0000";
    expected = false;
  };

  testIsColorWithEmptyAttrs = {
    expr = libSchemes.color.isColor { };
    expected = false;
  };

  testIsColorWithWrongAttr = {
    expr = libSchemes.color.isColor { rgb = "rgb(0,0,0)"; };
    expected = false;
  };

  testIsColorWithDecAttr = {
    expr = libSchemes.color.isColor {
      dec = [
        0
        0
        0
      ];
    };
    expected = true;
  };

  testIsColorWithWrongLength = {
    expr = libSchemes.color.isColor {
      dec = [
        0
        0
      ];
    };
    expected = false;
  };

  testIsColorWithDecNotList = {
    expr = libSchemes.color.isColor { dec = "not a list"; };
    expected = false;
  };
}
