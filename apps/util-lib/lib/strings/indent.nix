/**
  Prepend indentation spaces to a string.

  # Type

  ```
  indent :: int -> string -> string
  ```

  # Example

  ```nix
  indent 2 "hello"
  => "  hello"
  ```
*/
{ libSelf, ... }: count: str: (libSelf.strings.mkIndentPrefix count) + str
