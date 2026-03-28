/**
  Convert an RGB decimal list to a hexadecimal color string.

  # Type

  ```
  toHex :: [int] -> string
  ```

  # Example

  ```nix
  toHex [ 255 85 0 ]
  => "#FF5500"
  ```
*/
{ lib, ... }:
color:
lib.pipe color [
  (lib.map (dec: "${lib.optionalString (dec < 16) "0"}${lib.toHexString dec}"))
  lib.concatStrings
  (hex: "#${hex}")
]
