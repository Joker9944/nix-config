/**
  Calculate the per-channel ratios between two RGB color lists.

  Each ratio is computed as `(target - base) / 255`, resulting in a value in
  the range `[-1.0, 1.0]`. Positive values indicate the target channel is
  brighter than the base; negative values indicate it is darker.

  # Type

  ```
  calcColorRatios :: [number] -> [number] -> [number]
  ```

  # Example

  ```nix
  calcColorRatios [ 125 125 125 ] [ 200 200 200 ]
  => [ 0.29411764705882354 0.29411764705882354 0.29411764705882354 ]

  calcColorRatios [ 200 200 200 ] [ 125 125 125 ]
  => [ -0.29411764705882354 -0.29411764705882354 -0.29411764705882354 ]
  ```
*/
{ lib, ... }: lib.zipListsWith (a: b: (b - a) / 255.0)
