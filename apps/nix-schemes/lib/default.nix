{ lib, ... }@args:
lib.fix (
  self:
  lib.pipe ./. [
    builtins.readDir
    lib.attrNames
    (lib.filter (filename: filename != "default.nix"))
    (lib.map (filename: {
      name = lib.removeSuffix ".nix" filename;
      value = import (lib.path.append ./. filename) (
        args
        // {
          inherit self;
        }
      );
    }))
    lib.listToAttrs
  ]
)
