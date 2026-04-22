/**
  Convert a float to a minimal string representation, stripping trailing zeros
  and the decimal point when not needed.

  # Type

  ```
  toStringFloat :: number -> string
  ```

  # Example

  ```nix
  toStringFloat 0.5
  => "0.5"

  toStringFloat 1.0
  => "1"
  ```
*/
{ lib, ... }:
float:
let
  str = toString float;
  hasDecimal = lib.hasInfix "." str;
  stripZeros = s: lib.foldl' (acc: _: lib.removeSuffix "0" acc) s (lib.range 0 9);
  stripped = if hasDecimal then stripZeros str else str;
in
lib.removeSuffix "." stripped
