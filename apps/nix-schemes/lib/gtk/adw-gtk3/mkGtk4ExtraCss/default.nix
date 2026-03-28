/**
  Generate GTK4 CSS for libadwaita theme customization.
  Outputs CSS that can be placed in ~/.config/gtk-4.0/gtk.css.

  # Type

  ```
  mkGtk4ExtraCss :: { scheme, accents, accent? } -> string
  ```

  # Arguments

  - `scheme`: Color scheme with palette and variant
  - `accents`: Accent color map (from mkAccentsFromPalette or mkAccentsFromColor)
  - `accent`: Which accent to use (default: "blue")

  # Example

  ```nix
  mkGtk4ExtraCss {
    inherit scheme;
    accents = gtk.mkAccentsFromPalette scheme.palette;
    accent = "purple";
  }
  ```
*/
_:
{
  scheme,
  accents,
  accent ? "blue",
}:
import ./templates/gtk4.css.nix scheme.palette accents accent
