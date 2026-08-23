/**
  Build a color from hue, saturation and lightness, the inverse of `toHsl`.

  # Type

  ```
  fromHsl :: { h :: number, s :: number, l :: number } -> color
  ```

  # Example

  ```nix
  fromHsl { h = 295.1; s = 0.51; l = 0.62; }
  => { dec = [ 200 110 208 ]; ... }
  ```
*/
{
  libSelf,
  libUtil,
  libMath,
  lib,
  ...
}:
{
  h,
  s,
  l,
}:
let
  amplitude = s * lib.min l (1 - l);

  # One piecewise-linear ramp over the wheel. Equivalent to the six-way sextant
  # form and rather less of it.
  channel =
    n:
    let
      offset = n + h / 30;
      k = if offset >= 12 then offset - 12 else offset;
    in
    l - amplitude * lib.max (-1) (lib.min (k - 3) (lib.min (9 - k) 1));
  # Red, green and blue are the same ramp sampled a third of the wheel apart.
  raw = [
    (channel 0)
    (channel 8)
    (channel 4)
  ];
in
lib.pipe raw [
  (lib.map (c: c * 255))
  (lib.map libMath.round)
  (lib.map (libUtil.numbers.clamp 0 255))
  libSelf.color.mkColor
]
