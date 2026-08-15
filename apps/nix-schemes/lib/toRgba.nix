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
{
  lib,
  libSelf,
  libUtil,
  ...
}:
color: alpha:
lib.pipe color [
  libSelf.toRgb
  (rgb: "${rgb},${libUtil.numbers.toStringFloat alpha}")
]
