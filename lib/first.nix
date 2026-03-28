/**
  Return the first element of a list.

  # Type

  ```
  first :: [a] -> a
  ```

  # Example

  ```nix
  first [ 1 2 3 ]
  => 1
  ```
*/
{ lib, ... }: list: lib.elemAt list 0
