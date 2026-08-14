/**
  Return the last element of a list, or null if the list is empty.

  # Type

  ```
  last :: [a] -> a | null
  ```

  # Example

  ```nix
  last [ 1 2 3 ]
  => 3

  last [ ]
  => null
  ```
*/
{ lib, ... }: list: if list == [ ] then null else lib.elemAt list ((lib.length list) - 1)
