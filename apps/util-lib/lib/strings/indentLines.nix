/**
  Indent each line of a multiline string.

  # Type

  ```
  indentLines :: int -> string -> string
  ```

  # Example

  ```nix
  indentLines 2 "line1\nline2"
  => "  line1\n  line2"
  ```
*/
{ libSelf, lib, ... }:
count: lines:
lib.pipe lines [
  (lib.splitString "\n")
  (lib.map (libSelf.strings.indent count))
  (lib.concatStringsSep "\n")
]
