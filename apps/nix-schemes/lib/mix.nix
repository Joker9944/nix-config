{
  self,
  lib,
  custom,
  ...
}:
a: b: weight:
lib.pipe b [
  (lib.zipListsWith (a: b: a * (1 - weight) + b * weight) a)
  (lib.map custom.math.round)
  self.mkColor
]
