/**
  adw-gtk3 theme CSS generation utilities.
  Generate custom CSS to apply color schemes to GTK3 and GTK4 applications
  using the adw-gtk3 theme.
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
