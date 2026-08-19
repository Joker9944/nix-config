/**
  WCAG contrast ratio between two colors, in the range `[1, 21]`.

  1 is two identical colors, 21 is black against white. WCAG AA asks for 4.5
  for body text, 3 for large text and UI components.

  # Type

  ```
  contrastRatio :: (color | [int]) -> (color | [int]) -> number
  ```

  # Example

  ```nix
  contrastRatio [ 0 0 0 ] [ 255 255 255 ]
  => 21

  contrastRatio [ 217 83 107 ] [ 28 20 40 ]
  => 4.575929158145937
  ```
*/
{ libSelf, lib, ... }:
a: b:
let
  luminances = lib.map libSelf.color.relativeLuminance [
    a
    b
  ];
in
((lib.foldl' lib.max 0 luminances) + 0.05) / ((lib.foldl' lib.min 1 luminances) + 0.05)
