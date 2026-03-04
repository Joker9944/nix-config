{
  libSchemes,
  lib,
  custom,
  ...
}:
a: b: weight:
let
  aDec = if libSchemes.isColor a then a.dec else a;
  bDec = if libSchemes.isColor b then b.dec else b;
in
lib.pipe bDec [
  (lib.zipListsWith (a: b: a * (1 - weight) + b * weight) aDec)
  (lib.map custom.math.round)
  libSchemes.mkColor
]
