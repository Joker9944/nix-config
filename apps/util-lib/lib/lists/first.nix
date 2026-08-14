/**
  Return the first element of a list, or null if the list is empty.

  # Type

  ```
  first :: [a] -> a | null
  ```

  # Example

  ```nix
  first [ 1 2 3 ]
  => 1

  first [ ]
  => null
  ```
*/
{ lib, ... }: list: if list == [ ] then null else lib.elemAt list 0
