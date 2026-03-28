/**
  Check if a value is a valid color object.
  A valid color object is an attrset with a `dec` attribute that is a list of 3 elements.

  # Type

  ```
  isColor :: a -> bool
  ```

  # Example

  ```nix
  isColor (mkColor [ 255 0 0 ])
  => true

  isColor [ 255 0 0 ]
  => false
  ```
*/
{ lib, ... }:
color:
lib.isAttrs color && lib.hasAttr "dec" color && lib.isList color.dec && lib.length color.dec == 3
