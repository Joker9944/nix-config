{ lib, ... }:
{
  scheme,
  accents,
  accent ? "blue",
}:
lib.concatStrings [
  (import ./templates/gtk3-base.css.nix scheme.palette accents.${accent})
  (lib.optionalString (scheme.variant == "dark") (import ./templates/gtk3-dark.css.nix))
]
