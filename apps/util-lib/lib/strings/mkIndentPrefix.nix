/**
  Generate a string of spaces for indentation.

  # Type

  ```
  mkIndentPrefix :: int -> string
  ```

  # Example

  ```nix
  mkIndentPrefix 4
  => "    "
  ```
*/
{ lib, ... }: count: lib.concatStrings (lib.genList (_: " ") count)
