/**
  Return the last element of a list.

  # Type

  ```
  last :: [a] -> a
  ```

  # Example

  ```nix
  last [ 1 2 3 ]
  => 3
  ```
*/
{ lib, ... }: list: lib.elemAt list ((lib.length list) - 1)
