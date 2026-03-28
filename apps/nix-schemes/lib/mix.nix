/**
  Mix two colors together with a specified weight.
  Weight of 0 returns the first color, weight of 1 returns the second color.

  # Type

  ```
  mix :: (color | [int]) -> (color | [int]) -> number -> color
  ```

  # Example

  ```nix
  mix [ 255 0 0 ] [ 0 0 255 ] 0.5
  => { dec = [ 128 0 128 ]; ... }
  ```
*/
{
  libSchemes,
  lib,
  custom,
  ...
}:
a: b: weight:
let
  aDec = if libSchemes.isColor a then a.dec else a;
  bDec = if libSchemes.isColor b then b.dec else b;
in
lib.pipe bDec [
  (lib.zipListsWith (a: b: a * (1 - weight) + b * weight) aDec)
  (lib.map custom.math.round)
  libSchemes.mkColor
]
