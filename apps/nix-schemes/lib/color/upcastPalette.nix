/**
  Fill in the base24 slots a palette lacks. A slot the palette already carries is kept
  and feeds whatever derives from it.

  `base10` and `base11` continue the background ramp downwards by the step `base00` takes
  to `base01`; the six bright accents are their normal counterparts lightened.

  # Type

  ```
  upcastPalette :: { lightenWeight :: float } -> palette -> palette
  ```

  # Arguments

  - `lightenWeight`: how far the bright accents are lightened towards white

  # Example

  ```nix
  upcastPalette { } { base00 = <color>; … base0F = <color>; }
  => { base00 = <color>; … base17 = <color>; }
  ```
*/
{
  lib,
  libSelf,
  libUtil,
  libMath,
  ...
}:
{
  lightenWeight ? 0.2,
}:
palette:
let
  adjust =
    color: ratios:
    lib.pipe ratios [
      (lib.zipListsWith (dec: ratio: dec + 255 * ratio) color)
      (lib.map libMath.round)
      (lib.map (libUtil.numbers.clamp 0 255))
      libSelf.color.mkColor
    ];

  invert = lib.map (n: -n);
in
lib.fix (
  self:
  {
    base10 = adjust palette.base00.dec (
      invert (libSelf.color.calcColorRatios palette.base00.dec palette.base01.dec)
    );
    base11 = adjust self.base10.dec (
      invert (libSelf.color.calcColorRatios palette.base01.dec palette.base02.dec)
    );
    base12 = palette.base08.lighten lightenWeight;
    base13 = palette.base0A.lighten lightenWeight;
    base14 = palette.base0B.lighten lightenWeight;
    base15 = palette.base0C.lighten lightenWeight;
    base16 = palette.base0D.lighten lightenWeight;
    base17 = palette.base0E.lighten lightenWeight;
  }
  // palette
)
