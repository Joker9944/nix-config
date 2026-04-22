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
  libSchemes,
  ...
}:
base: slug:
let
  scheme = libSchemes.fromYaml "${inputs.schemes}/${base}/${slug}.yaml";
in
libSchemes.mkScheme {
  inherit (scheme)
    system
    name
    author
    variant
    ;

  palette = lib.pipe scheme.palette [
    (lib.mapAttrs (_: hex: libSchemes.fromHex hex))
    (lib.mapAttrs (_: dec: libSchemes.mkColor dec))
  ];
}
