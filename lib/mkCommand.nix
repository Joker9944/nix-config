/**
  Build a command string from a nested list of arguments.
  Flattens the list and joins elements with spaces.

  # Type

  ```
  mkCommand :: [string | [string]] -> string
  ```

  # Example

  ```nix
  mkCommand [ "cmd" [ "--flag" "value" ] "arg" ]
  => "cmd --flag value arg"
  ```
*/
{ lib, ... }:
elems:
lib.pipe elems [
  lib.flatten
  (lib.concatStringsSep " ")
]
