{
  self,
  lib,
  custom,
  ...
}:
a: factor:
let
  aDec = if self.isColor a then a.dec else a;
in
lib.pipe aDec [
  (lib.map (c: c * factor))
  (lib.map custom.math.round)
  (lib.map (self.clamp 0 255))
  self.mkColor
]
