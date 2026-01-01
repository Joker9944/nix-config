{ self, ... }:
dec: with self; {
  inherit dec;
  hex = toHex dec;
  rgb = toRgb dec;
  rgba = toRgba dec;
  mix = mix dec;
  adjust = adjust dec;
  lighten = lighten dec;
  darken = darken dec;
}
