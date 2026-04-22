/**
  Create an accent color map from a scheme palette.
  Maps semantic accent names to appropriate palette colors.

  Note: `orange` and `pink` are interpolated since base16 palettes don't include them.
  Orange is a 50% mix of red and yellow, pink is red lightened by 33%.

  # Type

  ```
  mkAccentsFromPalette :: palette -> { blue, teal, green, yellow, orange, red, pink, purple, slate :: color }
  ```

  # Example

  ```nix
  mkAccentsFromPalette scheme.palette
  => { blue = palette.base0D; teal = palette.base0C; green = palette.base0B; ... }
  ```
*/
_: palette: {
  blue = palette.base0D;
  teal = palette.base0C;
  green = palette.base0B;
  yellow = palette.base09;
  orange = palette.base08.mix palette.base09 0.5; # red yellow 50% mix
  red = palette.base08;
  pink = palette.base08.mix palette.base06 0.33; # red white 33% mix
  purple = palette.base0E;
  slate = palette.base03;
}
