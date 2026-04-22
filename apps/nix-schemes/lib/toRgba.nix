/**
  Convert an RGB decimal list to a CSS rgba() string with alpha channel.

  # Type

  ```
  toRgba :: [int] -> number -> string
  ```

  # Example

  ```nix
  toRgba [ 255 85 0 ] 0.5
  => "255,85,0,0.5"
  ```
*/
{ lib, libSchemes, ... }:
color: alpha:
lib.pipe color [
  libSchemes.toRgb
  (rgb: "${rgb},${libSchemes.util.toStringFloat alpha}")
]
