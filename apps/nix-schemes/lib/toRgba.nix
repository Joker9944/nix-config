{ lib, ... }:
color: alpha:
lib.pipe color [
  (lib.map toString)
  (lib.concatStringsSep ",")
  (rgb: "rgba(${rgb},${toString alpha})")
]
