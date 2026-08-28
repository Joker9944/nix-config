/**
  Map the palette onto human-readable color words, per the
  [base24 styling guide](https://github.com/tinted-theming/base24/blob/main/styling.md).

  The color words are ANSI-framed: `yellow.normal` is ANSI 3, so `base0A`, and `base09`
  (orange) carries no color word of its own.

  # Type

  ```
  named :: palette -> { background, foreground, black, red, … :: { <variant> :: color } }
  ```

  # Example

  ```nix
  named scheme.palette
  => {
    background = { darker = <color>; dark = <color>; normal = <color>; … };
    red = { normal = <color>; bright = <color>; };
    …
  }
  ```
*/
_: palette: {
  background = {
    darker = palette.base11;
    dark = palette.base10;
    normal = palette.base00;
    light = palette.base01;
    lighter = palette.base02;
  };

  foreground = {
    darker = palette.base03;
    dark = palette.base04;
    normal = palette.base05;
    light = palette.base06;
    lighter = palette.base07;
  };

  black = {
    normal = palette.base00;
    bright = palette.base03;
  };

  red = {
    normal = palette.base08;
    bright = palette.base12;
  };

  green = {
    normal = palette.base0B;
    bright = palette.base14;
  };

  yellow = {
    normal = palette.base0A;
    bright = palette.base13;
  };

  blue = {
    normal = palette.base0D;
    bright = palette.base16;
  };

  magenta = {
    normal = palette.base0E;
    bright = palette.base17;
  };

  cyan = {
    normal = palette.base0C;
    bright = palette.base15;
  };

  white = {
    normal = palette.base05;
    bright = palette.base07;
  };
}
