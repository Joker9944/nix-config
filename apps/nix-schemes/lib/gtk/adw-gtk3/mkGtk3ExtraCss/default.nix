/**
  Generate GTK3 CSS for adw-gtk3 theme customization.
  Outputs CSS that can be placed in ~/.config/gtk-3.0/gtk.css.

  # Type

  ```
  mkGtk3ExtraCss :: { scheme, accents, accent? } -> string
  ```

  # Arguments

  - `scheme`: Color scheme with palette and variant
  - `accents`: Accent color map (from mkAccentsFromPalette or mkAccentsFromColor)
  - `accent`: Which accent to use (default: "blue")

  # Example

  ```nix
  mkGtk3ExtraCss {
    inherit scheme;
    accents = gtk.mkAccentsFromPalette scheme.palette;
    accent = "purple";
  }
  ```
*/
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
