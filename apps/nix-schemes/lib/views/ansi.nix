/**
  Map the palette onto the sixteen ANSI terminal colors, per the
  [base24 styling guide](https://github.com/tinted-theming/base24/blob/main/styling.md).

  # Type

  ```
  ansi :: palette -> { "0" … "F" :: color }
  ```

  # Example

  ```nix
  ansi scheme.palette
  => { "0" = <color>; "1" = <color>; … }
  ```
*/
_: palette: {
  "0" = palette.base00;
  "8" = palette.base03;
  "1" = palette.base08;
  "9" = palette.base12;
  "2" = palette.base0B;
  "A" = palette.base14;
  "3" = palette.base0A;
  "B" = palette.base13;
  "4" = palette.base0D;
  "C" = palette.base16;
  "5" = palette.base0E;
  "D" = palette.base17;
  "6" = palette.base0C;
  "E" = palette.base15;
  "7" = palette.base05;
  "F" = palette.base07;
}
