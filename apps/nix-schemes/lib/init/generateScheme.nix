/**
  Generate a color scheme from the tinted-theming schemes repository.
  Returns a scheme object with a chainable `transform` method.

  # Type

  ```
  generateScheme :: string -> string -> scheme
  ```

  # Arguments

  - `base`: The scheme system ("base16" or "base24")
  - `slug`: The scheme name slug (e.g., "gruvbox-dark-hard")

  # Example

  ```nix
  generateScheme "base16" "gruvbox-dark-hard"
  => {
    system = "base16";
    name = "Gruvbox dark, hard";
    author = "...";
    variant = "dark";
    palette = { base00 = <color>; base01 = <color>; ... };
    transform = <function>;
  }
  ```
*/
{
  inputs,
  lib,
  libSelf,
  ...
}:
base: slug:
let
  scheme = libSelf.fromYaml "${inputs.schemes}/${base}/${slug}.yaml";
in
libSelf.mkScheme {
  inherit (scheme)
    system
    name
    author
    variant
    ;

  palette = lib.pipe scheme.palette [
    (lib.mapAttrs (_: hex: libSelf.fromHex hex))
    (lib.mapAttrs (_: dec: libSelf.mkColor dec))
  ];
}
