{ lib, ... }:
{
  dir,
  types ? [
    "regular"
    "directory"
    "symlink"
  ],
  exclude ? [ ],
}:
lib.pipe dir [
  builtins.readDir
  (lib.filterAttrs (_: filetype: lib.elem filetype types))
  lib.attrNames
  (lib.map (filename: lib.path.append dir filename))
  (lib.filter (path: !lib.elem path exclude))
]
