/**
  Initialize libSchemes with pkgs to enable impure functions.
  Returns the full libSchemes with additional functions that require pkgs.

  # Type

  ```
  init :: pkgs -> libSchemes
  ```

  # Example

  ```nix
  let
    libSchemes = inputs.nix-schemes.lib.init pkgs;
  in
  libSchemes.generateScheme "base16" "gruvbox-dark-hard"
  ```
*/
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
