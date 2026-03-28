/**
  Convert an RGB decimal list to a CSS rgba() string with alpha channel.

  # Type

  ```
  toRgba :: [int] -> number -> string
  ```

  # Example

  ```nix
  toRgba [ 255 85 0 ] 0.5
  => "rgba(255,85,0,0.5)"
  ```
*/
{ lib, ... }:
color: alpha:
let
  # Format alpha by removing trailing zeros after decimal point
  formatAlpha =
    a:
    let
      str = toString a;
      hasDecimal = lib.hasInfix "." str;
      stripZeros = s: lib.foldl' (acc: _: lib.strings.removeSuffix "0" acc) s (lib.range 0 9);
      stripped = if hasDecimal then stripZeros str else str;
    in
    lib.strings.removeSuffix "." stripped;
in
lib.pipe color [
  (lib.map toString)
  (lib.concatStringsSep ",")
  (rgb: "rgba(${rgb},${formatAlpha alpha})")
]
