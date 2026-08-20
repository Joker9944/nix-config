/**
  Generate a color scheme from the vendored tinted-theming schemes.

  # Type

  ```
  generateScheme :: string -> string -> scheme
  ```

  # Arguments

  - `schemeSystem`: The scheme system ("base16" or "base24")
  - `schemeSlug`: The scheme name slug (e.g., "gruvbox-dark-hard")

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
  lib,
  libSelf,
  ...
}:
schemeSystem: schemeSlug:
let
  scheme = import (../vendor/schemes + "/${schemeSystem}/${schemeSlug}.nix");
in
libSelf.color.mkScheme {
  inherit (scheme)
    system
    name
    author
    variant
    ;

  palette = lib.pipe scheme.palette [
    (lib.mapAttrs (_: hex: libSelf.color.fromHex hex))
    (lib.mapAttrs (_: dec: libSelf.color.mkColor dec))
  ];
}
