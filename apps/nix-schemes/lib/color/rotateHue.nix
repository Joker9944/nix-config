/**
  Turn a color around the wheel by an angle in degrees, holding saturation and
  lightness fixed. Negative angles turn the other way.

  # Type

  ```
  rotateHue :: (color | [int]) -> number -> color
  ```

  # Example

  ```nix
  rotateHue [ 200 110 208 ] (-120)
  => { dec = [ 110 208 200 ]; ... }
  ```
*/
{ libSelf, ... }:
color: degrees:
let
  hsl = libSelf.color.toHsl color;
  turned = hsl.h + degrees;
in
libSelf.color.fromHsl (hsl // { h = turned - 360 * builtins.floor (turned / 360); })
