/**
  Collect a directory tree of modules into a flat attribute set, keyed by the path
  segments below `dir` joined with `-` and carrying `prefix` as the first segment.

  A directory holding a `default.nix` is a single module and yields one entry; a
  directory without one is a namespace and is recursed into, contributing its name to
  the key. Anything that is neither a `.nix` file nor a directory is skipped.

  # Type

  ```
  mkModules :: {
    dir :: path,
    prefix :: string,
    exclude :: [path]?,
    args :: attrs?,
  } -> attrsOf module
  ```

  # Arguments

  - `dir`: Directory to collect from
  - `prefix`: First segment of every key
  - `exclude` (optional): Paths to skip
  - `args` (optional): When set, each module is imported via
    `lib.modules.importApply path args` instead of as a bare path

  # Example

  ```nix
  # public/extensions/sops.nix, public/tidy/{default,timer}.nix
  mkModules { dir = ./public; prefix = "public"; }
  => { public-extensions-sops = …; public-tidy = …; }
  ```
*/
{ lib, libUtil, ... }:
{
  dir,
  exclude ? [ ],
  prefix,
  args ? null,
  ...
}:
let
  isModule = path: builtins.pathExists (lib.path.append path "default.nix");

  collect =
    parent: current:
    lib.concatMap
      (
        path:
        let
          base = lib.baseNameOf path;
          name = "${parent}-${lib.removeSuffix ".nix" base}";
          entry = {
            inherit name;
            value = if args == null then path else lib.modules.importApply path args;
          };
        in
        if lib.filesystem.pathIsDirectory path then
          if isModule path then [ entry ] else collect name path
        else
          lib.optional (lib.hasSuffix ".nix" base) entry
      )
      (
        libUtil.files.list {
          inherit exclude;
          dir = current;
        }
      );

  entries = collect prefix dir;

  names = lib.map (entry: entry.name) entries;
  duplicates = lib.unique (lib.filter (name: lib.count (other: other == name) names > 1) names);
in
lib.throwIf (duplicates != [ ])
  "mkModules: ${toString dir} yields duplicate names: ${lib.concatStringsSep ", " duplicates}"
  (lib.listToAttrs entries)
