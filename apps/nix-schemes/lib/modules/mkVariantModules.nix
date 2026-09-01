/**
  Build one module per variant from a single template, each declaring its own
  `enable` flag under `schemes.<variant>`.

  The template is imported with `lib.modules.importApply`, so it keeps pointing at
  its own path in option errors, and receives the variant name alongside a display
  name for its descriptions.

  # Type

  ```
  mkVariantModules :: attrsOf string -> path -> attrsOf module
  ```

  # Example

  ```nix
  mkVariantModules {
    firefox = "Firefox";
    librewolf = "LibreWolf";
  } ./modules/home/firefox.nix
  => {
    firefox = <module>;
    librewolf = <module>;
  }
  ```
*/
{ lib, flake, ... }:
variants: path:
lib.mapAttrs (
  variant: displayName: lib.modules.importApply path { inherit flake variant displayName; }
) variants
