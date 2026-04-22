/**
  Create a color object from an RGB decimal list.
  The color object includes multiple format representations and manipulation methods.

  # Type

  ```
  mkColor :: [int] -> color
  ```

  # Example

  ```nix
  mkColor [ 255 85 0 ]
  => {
    dec = [ 255 85 0 ];
    hex = "FF5500";
    rgb = "255,85,0";
    rgba = <function>;
    xrgb = "FF/55/00";
    mix = <function>;
    adjust = <function>;
    lighten = <function>;
    darken = <function>;
    red = 255;
    green = 85;
    blue = 0;
  }
  ```
*/
{ libSchemes, ... }:
dec: with libSchemes; {
  inherit dec;
  hex = toHex dec;
  rgb = toRgb dec;
  rgba = toRgba dec;
  xrgb = toXrgb dec;
  mix = mix dec;
  adjust = adjust dec;
  lighten = lighten dec;
  darken = darken dec;
  red = red dec;
  green = green dec;
  blue = blue dec;
}
