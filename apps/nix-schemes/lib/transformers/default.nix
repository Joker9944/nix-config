/**
  Collection of scheme transformers.
  Transformers add or modify scheme attributes and can be chained via `scheme.transform`.
*/
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
