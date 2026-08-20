/**
  Extract the blue channel from an RGB decimal list.

  # Type

  ```
  blue :: [int] -> int
  ```

  # Example

  ```nix
  blue [ 255 85 0 ]
  => 0
  ```
*/
{ lib, ... }: color: lib.elemAt color 2
