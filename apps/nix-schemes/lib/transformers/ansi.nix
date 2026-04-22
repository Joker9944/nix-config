/**
  Add ANSI color mappings (0-F) to the scheme.
  Maps base16/base24 palette colors to standard ANSI terminal colors.

  # Example

  ```nix
  scheme.transform transformers.ansi
  => { ansi = { "0" = <color>; "1" = <color>; ... }; ... }
  ```
*/
_: scheme: _:
let
  inherit (scheme) palette;
  isBase24 = scheme.system == "base24";
in
{
  ansi = {
    # https://github.com/Base24/base24/blob/master/styling.md
    "0" = palette.base01;
    "8" = palette.base02;
    "1" = palette.base08;
    "9" = if isBase24 then palette.base12 else palette.base08;
    "2" = palette.base0B;
    "A" = if isBase24 then palette.base14 else palette.base0B;
    "3" = palette.base09;
    "B" = if isBase24 then palette.base13 else palette.base09;
    "4" = palette.base0D;
    "C" = if isBase24 then palette.base16 else palette.base0D;
    "5" = palette.base0E;
    "D" = if isBase24 then palette.base17 else palette.base0E;
    "6" = palette.base0C;
    "E" = if isBase24 then palette.base15 else palette.base0C;
    "7" = palette.base06;
    "F" = palette.base07;
  };
}
