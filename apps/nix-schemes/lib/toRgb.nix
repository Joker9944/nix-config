{ lib, ... }:
color:
lib.pipe color [
  (lib.map toString)
  (lib.concatStringsSep ",")
  (rgb: "rgb(${rgb})")
]
