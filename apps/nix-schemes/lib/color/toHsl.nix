/**
  Convert a color to hue, saturation and lightness.

  `h` is in degrees `[0, 360)`, `s` and `l` are fractions in `[0, 1]`. An
  achromatic color has no hue to report, so it gets `0`.

  # Type

  ```
  toHsl :: (color | [int]) -> { h :: number, s :: number, l :: number }
  ```

  # Example

  ```nix
  toHsl [ 200 110 208 ]
  => { h = 295.1020408163265; s = 0.5104166666666666; l = 0.6235294117647059; }
  ```
*/
{ libSelf, lib, ... }:
color:
let
  channels = lib.map (c: c / 255.0) (if libSelf.color.isColor color then color.dec else color);
  r = lib.elemAt channels 0;
  g = lib.elemAt channels 1;
  b = lib.elemAt channels 2;

  high = lib.max r (lib.max g b);
  low = lib.min r (lib.min g b);
  chroma = high - low;

  l = (high + low) / 2;

  # Which sextant of the wheel `high` names, scaled to degrees. The red case
  # runs negative below the seam at 0, where the wheel wraps.
  h =
    if high == r then
      60 * (g - b) / chroma + (if g < b then 360 else 0)
    else if high == g then
      60 * ((b - r) / chroma + 2)
    else
      60 * ((r - g) / chroma + 4);
in
if chroma == 0 then
  {
    h = 0;
    s = 0;
    inherit l;
  }
else
  {
    inherit h l;
    s = chroma / (1 - lib.max (2 * l - 1) (1 - 2 * l));
  }
