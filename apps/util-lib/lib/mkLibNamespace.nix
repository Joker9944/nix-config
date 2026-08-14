/**
  Load a directory into an attrset namespace: every `.nix` file becomes an
  attribute named after it, every subdirectory becomes a nested namespace via
  its own `default.nix`. All members are imported with the same argument set.

  The fixed-point is tied by the caller, once per flake, so `libSelf` in `args`
  refers to the whole tree at every depth rather than the enclosing namespace.

  # Type

  ```
  mkLibNamespace :: { context :: path, args :: attrs } -> attrs
  ```

  # Arguments

  - `context`: Directory to load; `default.nix` is skipped
  - `args`: Argument set each member is imported with

  # Example

  ```nix
  # lib/strings/default.nix
  { libSelf, ... }@args: libSelf.mkLibNamespace { context = ./.; inherit args; }
  => { indent = <fn>; indentLines = <fn>; mkCommand = <fn>; mkIndentPrefix = <fn>; }
  ```
*/
{ lib, ... }:
{
  context,
  args,
}:
lib.pipe context [
  builtins.readDir
  lib.attrNames
  (lib.filter (filename: filename != "default.nix"))
  (lib.map (filename: {
    name = lib.removeSuffix ".nix" filename;
    value = import (lib.path.append context filename) args;
  }))
  lib.listToAttrs
]
