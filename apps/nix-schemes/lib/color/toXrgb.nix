/**
  Convert an RGB decimal list to a xrgb color string.

  # Type

  ```
  toXrgb :: [int] -> string
  ```

  # Example

  ```nix
  toXrgb [ 255 85 0 ]
  => "FF/55/00"
  ```
*/
{ lib, ... }:
color:
lib.pipe color [
  (lib.map (dec: "${lib.optionalString (dec < 16) "0"}${lib.toHexString dec}"))
  (lib.concatStringsSep "/")
]
