{ lib, ... }@args:
lib.pipe ./. [
  builtins.readDir
  lib.attrNames
  (lib.filter (filename: filename != "default.nix"))
  (lib.map (filename: {
    name = lib.removeSuffix ".nix" filename;
    value = import (lib.path.append ./. filename) args;
  }))
  lib.listToAttrs
]
