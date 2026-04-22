/**
  Extract the red channel from an RGB decimal list.

  # Type

  ```
  red :: [int] -> int
  ```

  # Example

  ```nix
  red [ 255 85 0 ]
  => 255
  ```
*/
{ lib, ... }: color: lib.elemAt color 0
