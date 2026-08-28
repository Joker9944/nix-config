/**
  Compile a cursor theme for a scheme from the vendored Breeze templates. Requires pkgs (impure).

  XCursor has no recolouring hook at all — the format is pre-baked ARGB pixmaps, so there is
  no analogue to the stylesheet rewrite `mkIconTheme` performs on an icon pack. The way in is
  upstream of the format, at the SVGs Breeze is drawn in: `vendor/cursors/breeze` carries them
  with a `data-slot` on every paint, and `build.py` resolves those, rasterises and packs.

  Three formats come out of one theme directory, because all three are found the same way,
  by theme name under `share/icons`: XCursor for XWayland and GTK, KDE's `cursors_scalable`
  for KWin, and hyprcursor for Hyprland.

  Only the Breeze variant is templated. Breeze_Light is not a recolour of it — its outline is
  a translucent black rather than a colour, so a slot would not mean the same thing in both —
  and swapping `fill` with `outline` already yields the light-desktop cursor.

  # Type

  ```
  mkCursorTheme :: { scheme, colors } -> derivation
  ```

  # Arguments

  - `scheme`: Color scheme the theme is named after
  - `colors`: The nine paint slots, all of them — `schemes.cursors.colors` declares them
    and derives their defaults

  # Example

  ```nix
  mkCursorTheme {
    inherit scheme;
    inherit (config.schemes.cursors) colors;
  }
  ```
*/
{
  lib,
  pkgs,
  ...
}:
{
  scheme,
  colors,
}:
let
  paints = lib.mapAttrs (_: color: "#${color.hex}") colors;

  themeName = "Breeze-${scheme.meta.slug}";
in
pkgs.stdenvNoCC.mkDerivation {
  name = themeName;

  passthru.themeName = themeName;

  dontUnpack = true;

  nativeBuildInputs = with pkgs; [
    python3
    resvg
    xcursorgen
    hyprcursor
  ];

  preferLocalBuild = true;

  # Nothing in the tree is an executable, and the pixmaps are the bulk of it.
  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    python3 ${./build.py} \
      ${../../../vendor/cursors/breeze} \
      ${pkgs.writers.writeJSON "colors.json" paints} \
      ${themeName} \
      theme

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons"
    cp -a theme "$out/share/icons/${themeName}"

    runHook postInstall
  '';

  meta = {
    description = "Breeze cursors recoloured for ${scheme.meta.name}";
    license = lib.licenses.lgpl3Plus;
  };
}
