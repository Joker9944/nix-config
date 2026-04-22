/**
  Extract the green channel from an RGB decimal list.

  # Type

  ```
  green :: [int] -> int
  ```

  # Example

  ```nix
  green [ 255 85 0 ]
  => 85
  ```
*/
{ lib, ... }: color: lib.elemAt color 1
