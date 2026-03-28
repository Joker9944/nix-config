/**
  Darken a color by mixing it with black.
  Weight of 0 returns the original color, weight of 1 returns black.

  # Type

  ```
  darken :: (color | [int]) -> number -> color
  ```

  # Example

  ```nix
  darken [ 128 128 128 ] 0.5
  => { dec = [ 64 64 64 ]; ... }
  ```
*/
{ libSchemes, ... }:
a: weight:
libSchemes.mix a [
  0
  0
  0
] weight
