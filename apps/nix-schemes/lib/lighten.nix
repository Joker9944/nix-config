/**
  Lighten a color by mixing it with white.
  Weight of 0 returns the original color, weight of 1 returns white.

  # Type

  ```
  lighten :: (color | [int]) -> number -> color
  ```

  # Example

  ```nix
  lighten [ 128 128 128 ] 0.5
  => { dec = [ 192 192 192 ]; ... }
  ```
*/
{ libSchemes, ... }:
a: weight:
libSchemes.mix a [
  255
  255
  255
] weight
