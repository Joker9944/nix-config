{ lib, ... }:
color:
lib.pipe color [
  (lib.map (dec: "${lib.optionalString (dec < 16) "0"}${lib.toHexString dec}"))
  lib.concatStrings
  (hex: "#${hex}")
]
