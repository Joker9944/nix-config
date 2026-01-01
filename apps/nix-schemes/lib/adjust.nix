{
  self,
  lib,
  custom,
  ...
}:
a: factor:
lib.pipe a [
  (lib.map (c: c * factor))
  (lib.map custom.math.round)
  (lib.map (self.clamp 0 255))
  self.mkColor
]
