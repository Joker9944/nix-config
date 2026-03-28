/**
  Create an accent color map where all accent names map to the same color.

  # Type

  ```
  mkAccentsFromColor :: color -> { blue, teal, green, yellow, orange, red, pink, purple, slate :: color }
  ```

  # Example

  ```nix
  mkAccentsFromColor (mkColor [ 255 0 0 ])
  => { blue = <red>; teal = <red>; green = <red>; ... }
  ```
*/
{ lib, ... }:
color:
lib.pipe
  [
    "blue"
    "teal"
    "green"
    "yellow"
    "orange"
    "red"
    "pink"
    "purple"
    "slate"
  ]
  [
    (lib.map (name: {
      inherit name;
      value = color;
    }))
    lib.listToAttrs
  ]
