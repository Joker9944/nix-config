/**
  List directory contents with optional filtering by file type and exclusions.

  # Type

  ```
  ls :: { dir :: path, types :: [string]?, exclude :: [path]? } -> [path]
  ```

  # Arguments

  - `dir`: Directory path to list
  - `types`: File types to include (default: ["regular" "directory" "symlink"])
  - `exclude`: Paths to exclude from results

  # Example

  ```nix
  ls { dir = ./lib; types = [ "regular" ]; exclude = [ ./lib/default.nix ]; }
  => [ /path/to/lib/first.nix /path/to/lib/last.nix ... ]
  ```
*/
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
