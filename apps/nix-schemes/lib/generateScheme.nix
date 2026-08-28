/**
  Load a vendored tinted-theming scheme as a source: metadata plus a palette of hex
  strings. Pass it to `mkScheme` to get a scheme.

  # Type

  ```
  generateScheme :: string -> string -> source
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
    slug = "gruvbox-dark-hard";
    palette = { base00 = "#1D2021"; ... };
  }
  ```
*/
{ lib, ... }:
schemeSystem: schemeSlug:
let
  scheme = import (lib.path.append ../vendor/schemes "${schemeSystem}/${schemeSlug}.nix");
in
# Upstream states a slug only where the name does not reduce to the filename, and never
# disagrees with it. Taking the attr first keeps upstream authoritative all the same.
scheme // { slug = scheme.slug or schemeSlug; }
