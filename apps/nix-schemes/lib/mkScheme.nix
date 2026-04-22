/**
  Create a scheme object with a chainable `transform` method.
  The `transform` method accepts a function `(prevScheme: libSchemes: attrset)`
  whose return value is recursively merged into the scheme.

  # Type

  ```
  mkScheme :: { system, name, author, variant, palette } -> scheme
  ```

  # Example

  ```nix
  mkScheme {
    system = "base16";
    name = "My Scheme";
    author = "me";
    variant = "dark";
    palette = { base00 = mkColor [ 0 0 0 ]; };
  }
  => {
    system = "base16";
    name = "My Scheme";
    author = "me";
    variant = "dark";
    palette = { base00 = <color>; };
    transform = <function>;
  }
  ```
*/
{ lib, libSchemes, ... }:
{
  system,
  name,
  author,
  variant,
  palette,
}:
let
  transform =
    prevScheme: transformFunction:
    let
      currScheme = lib.recursiveUpdate prevScheme (transformFunction prevScheme libSchemes);
    in
    currScheme
    // {
      transform = transform currScheme;
    };
in
transform {
  inherit
    system
    name
    author
    variant
    palette
    ;
} (_: _: { })
