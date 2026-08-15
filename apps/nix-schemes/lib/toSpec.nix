/**
  Flatten a scheme into a plain serializable attrset — every color becomes
  `{ hex, rgb, dec }` and every function is dropped, so the result survives
  `builtins.toJSON`.

  Walks the whole scheme, so whatever the transformers added (`ansi`, the named
  colors, `accent`, …) comes along without this needing to know about them.

  # Type

  ```
  toSpec :: scheme -> attrs
  ```

  # Example

  ```nix
  toSpec scheme
  => {
       system = "base24"; name = "Dracula"; variant = "dark";
       palette.base00 = { hex = "282A36"; rgb = "40,42,54"; dec = [ 40 42 54 ]; };
       ansi."0" = { hex = "21222C"; … };
     }
  ```
*/
{ lib, libSelf, ... }:
scheme:
let
  toSpec =
    value:
    if libSelf.isColor value then
      { inherit (value) hex rgb dec; }
    else if lib.isAttrs value then
      lib.pipe value [
        (lib.filterAttrs (_: v: !lib.isFunction v))
        (lib.mapAttrs (_: toSpec))
      ]
    else
      value;
in
toSpec scheme
