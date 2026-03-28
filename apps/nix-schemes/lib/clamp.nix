/**
  Clamp a number to a specified range.

  # Type

  ```
  clamp :: number -> number -> number -> number
  ```

  # Example

  ```nix
  clamp 0 255 300
  => 255

  clamp 0 255 (-10)
  => 0
  ```
*/
_: min: max: n:
if n <= min then
  min
else if n >= max then
  max
else
  n
