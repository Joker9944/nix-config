/**
  Adjust a color's brightness by multiplying each channel by a factor.
  Results are clamped to the 0-255 range.

  # Type

  ```
  adjust :: (color | [int]) -> number -> color
  ```

  # Example

  ```nix
  adjust [ 128 128 128 ] 0.5
  => { dec = [ 64 64 64 ]; ... }

  adjust [ 128 128 128 ] 2
  => { dec = [ 255 255 255 ]; ... }
  ```
*/
{
  libSchemes,
  lib,
  custom,
  ...
}:
a: factor:
let
  aDec = if libSchemes.isColor a then a.dec else a;
in
lib.pipe aDec [
  (lib.map (c: c * factor))
  (lib.map custom.math.round)
  (lib.map (libSchemes.util.clamp 0 255))
  libSchemes.mkColor
]
