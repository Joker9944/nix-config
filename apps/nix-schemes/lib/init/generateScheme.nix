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
  scheme = libSchemes.fromYaml "${base}-${slug}" "${inputs.schemes}/${base}/${slug}.yaml";

  palette = lib.pipe scheme.palette [
    (lib.mapAttrs (_: hex: libSchemes.fromHex hex))
    (lib.mapAttrs (_: dec: libSchemes.mkColor dec))
  ];

  modifiedScheme = {
    inherit (scheme)
      system
      name
      author
      variant
      ;
    inherit palette;
  };

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
transform modifiedScheme (_: _: { })
