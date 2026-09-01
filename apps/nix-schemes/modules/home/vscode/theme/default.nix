/**
  Map a scheme onto a VS Code color theme.

  The slot assignments come from tinted-theming/tinted-vscode's `base24.mustache`; the two
  tables it drives live in [](./colors.nix) and [](./tokens.nix). Its terminal block follows
  the out-of-date `Base24/base24` ANSI table, so `colors.nix` reads the scheme's own `ansi`
  view there instead.

  # Type

  ```
  theme :: scheme -> { name, type, semanticHighlighting, colors, tokenColors }
  ```

  # Example

  ```nix
  theme config.schemes.scheme
  => { name = "ORCHIDLIFT LUME"; type = "dark"; colors = { ... }; ... }
  ```
*/
scheme:
let
  hex = color: "#${color.hex}";

  # VS Code reads #RRGGBBAA, so translucent fills carry their alpha as a hex suffix.
  fade = alpha: color: "#${color.hex}${alpha}";

  args = {
    inherit (scheme)
      palette
      accent
      ansi
      status
      ;
    inherit hex fade;
  };
in
{
  "$schema" = "vscode://schemas/color-theme";
  inherit (scheme.meta) name;
  type = scheme.meta.variant;

  semanticHighlighting = true;

  colors = import ./colors.nix args;
  tokenColors = import ./tokens.nix {
    inherit (scheme) palette;
    inherit hex;
  };
}
