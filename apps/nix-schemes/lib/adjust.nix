{
  libSchemes,
  lib,
  custom,
  ...
}:
a: factor:
let
  aDec = if libSchemes.isColor a then a.dec else a;
in
lib.pipe aDec [
  (lib.map (c: c * factor))
  (lib.map custom.math.round)
  (lib.map (libSchemes.clamp 0 255))
  libSchemes.mkColor
]
