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
{ self, ... }: count: str: (self.mkIndentPrefix count) + str
