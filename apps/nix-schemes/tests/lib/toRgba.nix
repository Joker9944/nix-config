{ libSchemes, ... }:
{
  testToRgbaFull = {
    expr = libSchemes.toRgba [ 255 255 255 ] 1;
    expected = "rgba(255,255,255,1)";
  };

  testToRgbaHalf = {
    expr = libSchemes.toRgba [ 128 64 32 ] 0.5;
    expected = "rgba(128,64,32,0.500000)";
  };

  testToRgbaZero = {
    expr = libSchemes.toRgba [ 0 0 0 ] 0;
    expected = "rgba(0,0,0,0)";
  };
}
