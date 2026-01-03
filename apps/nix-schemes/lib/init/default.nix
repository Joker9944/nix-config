{ lib, self, ... }@args:
pkgs:
(lib.removeAttrs self [ "init" ])
// (lib.fix (
  selfPkgs:
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
          self = lib.recursiveUpdate self selfPkgs;
        }
      );
    }))
    lib.listToAttrs
  ]
))
