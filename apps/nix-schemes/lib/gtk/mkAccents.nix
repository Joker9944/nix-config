/**
  Build the nine GTK 4 accent colors for a scheme.

  In `palette` mode each name takes the palette color closest to it; `orange` and `pink`
  are interpolated, since base16 palettes carry neither. In `uniform` mode every name
  takes the scheme accent, which is what a theme naming one color wants.

  # Type

  ```
  mkAccents :: { scheme, mode ? "palette" } -> { blue, teal, green, yellow, orange, red, pink, purple, slate :: color }
  ```

  # Arguments

  - `scheme`: the scheme to derive from
  - `mode`: `"palette"` to spread the palette across the nine names, `"uniform"` to
    collapse them onto `scheme.accent`

  # Example

  ```nix
  mkAccents { inherit scheme; }
  => { blue = <base0D>; teal = <base0C>; green = <base0B>; … }
  ```
*/
{ lib, ... }:
{
  scheme,
  mode ? "palette",
}:
let
  inherit (scheme) palette;

  names = [
    "blue"
    "teal"
    "green"
    "yellow"
    "orange"
    "red"
    "pink"
    "purple"
    "slate"
  ];
in
if mode == "uniform" then
  lib.genAttrs names (_: scheme.accent)
else
  {
    blue = palette.base0D;
    teal = palette.base0C;
    green = palette.base0B;
    yellow = palette.base0A;
    orange = palette.base09;
    red = palette.base08;
    pink = palette.base08.mix palette.base06 0.33; # red white 33% mix
    purple = palette.base0E;
    slate = palette.base03;
  }
