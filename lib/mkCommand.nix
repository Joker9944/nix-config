{ lib, ... }:
elems:
lib.pipe elems [
  lib.flatten
  (lib.concatStringsSep " ")
]
