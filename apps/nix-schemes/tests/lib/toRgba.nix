{ libSchemes, ... }:
{
  testToRgbaFull = {
    expr = libSchemes.color.toRgba [ 255 255 255 ] 1;
    expected = "255,255,255,1";
  };

  testToRgbaHalf = {
    expr = libSchemes.color.toRgba [ 128 64 32 ] 0.5;
    expected = "128,64,32,0.5";
  };

  testToRgbaQuarter = {
    expr = libSchemes.color.toRgba [ 128 64 32 ] 0.25;
    expected = "128,64,32,0.25";
  };

  testToRgbaZero = {
    expr = libSchemes.color.toRgba [ 0 0 0 ] 0;
    expected = "0,0,0,0";
  };
}
