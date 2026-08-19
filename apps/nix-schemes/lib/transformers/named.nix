/**
  Add semantic named color attributes to the scheme.
  Provides human-readable names like background, foreground, error, etc.

  Status colors are `info` blue, `warning` orange, `error` red and `success` green. The color
  words are ANSI-framed: `yellow.dull` is ANSI 3, so `base0A`, and `base09` (orange) carries no
  color word of its own.

  # Example

  ```nix
  scheme.transform transformers.named
  => {
    background = { normal = <color>; light = <color>; ... };
    foreground = { dark = <color>; normal = <color>; ... };
    info = <color>;
    warning = <color>;
    error = <color>;
    success = <color>;
    red = { dull = <color>; bright = <color>; };
    ...
  }
  ```
*/
{ lib, ... }:
scheme: _:
let
  inherit (scheme) palette;
  isBase24 = scheme.system == "base24";
in
{
  # https://github.com/tinted-theming/base24/blob/main/styling.md
  background = {
    normal = palette.base00;
    light = palette.base01;
    lighter = palette.base02;
  }
  // lib.optionalAttrs isBase24 {
    darker = palette.base11;
    dark = palette.base10;
  };

  foreground = {
    darker = palette.base03;
    dark = palette.base04;
    normal = palette.base05;
    light = palette.base06;
    lighter = palette.base07;
  };

  # Status colors follow the conventional UI hues, not the spec's text-editor guidance, which
  # assigns `base0F` to warnings — a dark red or brown that is hard to tell from `error`.
  info = palette.base0D;
  warning = palette.base09;
  error = palette.base08;
  success = palette.base0B;

  black = {
    dull = palette.base00;
    bright = palette.base03;
  };

  red = {
    dull = palette.base08;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base12;
  };

  green = {
    dull = palette.base0B;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base14;
  };

  yellow = {
    dull = palette.base0A;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base13;
  };

  blue = {
    dull = palette.base0D;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base16;
  };

  magenta = {
    dull = palette.base0E;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base17;
  };

  cyan = {
    dull = palette.base0C;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base15;
  };

  white = {
    dull = palette.base05;
    bright = palette.base07;
  };
}
