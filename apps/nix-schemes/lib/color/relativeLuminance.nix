/**
  WCAG relative luminance of a color, in the range `[0, 1]`.

  Each channel is linearized out of sRGB's transfer curve before being weighted,
  which is what separates this from a plain luma average: the weights alone
  describe cone sensitivity, but they only mean anything once the gamma encoding
  is undone.

  Constants are fixed by WCAG 2.2, "relative luminance".

  # Type

  ```
  relativeLuminance :: (color | [int]) -> number
  ```

  # Example

  ```nix
  relativeLuminance [ 0 0 0 ]
  => 0

  relativeLuminance [ 217 83 107 ]
  => 0.2199976355156877
  ```
*/
{
  libSelf,
  libMath,
  lib,
  ...
}:
color:
let
  linearize =
    channel:
    let
      c = channel / 255.0;
    in
    if c <= 0.04045 then c / 12.92 else libMath.pow ((c + 0.055) / 1.055) 2.4;
in
lib.pipe (if libSelf.isColor color then color.dec else color) [
  (lib.map linearize)
  (lib.zipListsWith (weight: channel: weight * channel) [
    0.2126
    0.7152
    0.0722
  ])
  (lib.foldl' (a: b: a + b) 0)
]
