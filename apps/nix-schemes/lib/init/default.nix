{ lib, libSchemes, ... }@args:
pkgs:
(lib.removeAttrs libSchemes [ "init" ])
// (lib.fix (
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
          inherit pkgs;
          libSchemes = lib.recursiveUpdate libSchemes self;
        }
      );
    }))
    lib.listToAttrs
  ]
))
