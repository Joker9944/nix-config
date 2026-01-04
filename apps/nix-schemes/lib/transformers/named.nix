{ lib, ... }:
scheme: _:
let
  inherit (scheme) palette;
  isBase24 = scheme.system == "base24";
in
{
  # https://github.com/Base24/base24/blob/master/styling.md
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
    dark = palette.base04;
    normal = palette.base05;
    light = palette.base06;
    lighter = palette.base07;
  };

  info = palette.base0D;
  warning = palette.base09;
  error = palette.base08;

  black = {
    dull = palette.base00;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base02;
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
    dull = palette.base09;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base13;
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
    dull = palette.base06;
  }
  // lib.optionalAttrs isBase24 {
    bright = palette.base07;
  };
}
