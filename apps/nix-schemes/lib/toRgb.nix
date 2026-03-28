/**
  Convert an RGB decimal list to a CSS rgb() string.

  # Type

  ```
  toRgb :: [int] -> string
  ```

  # Example

  ```nix
  toRgb [ 255 85 0 ]
  => "rgb(255,85,0)"
  ```
*/
{ lib, ... }:
color:
lib.pipe color [
  (lib.map toString)
  (lib.concatStringsSep ",")
  (rgb: "rgb(${rgb})")
]
