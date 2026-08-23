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
  mkCursorTheme :: { scheme, slots? } -> derivation
  ```

  # Arguments

  - `scheme`: Color scheme with a palette and an `accent` supplied by a transformer
  - `slots`: Colors overriding the defaults derived from the scheme

  # Example

  ```nix
  mkCursorTheme {
    inherit scheme;
    slots.accentAlt = libSchemes.color.mkColor [ 0 127 255 ];
  }
  ```
*/
{
  libSelf,
  lib,
  pkgs,
  ...
}:
{
  scheme,
  slots ? { },
}:
let
  inherit (scheme) palette;

  accent = libSelf.requireKey scheme "accent";

  hex = color: "#${color.hex}";

  # The cursor is drawn as a body inside an outline, so the two take opposite ends of the
  # palette and swap with the variant — that is the whole of what Breeze_Light would add.
  # The rest are Breeze's own semantics, which already line up with base24 slots.
  defaults = {
    fill = if scheme.variant == "dark" then palette.base00 else palette.base06;
    outline = if scheme.variant == "dark" then palette.base06 else palette.base00;

    # Drawn under a blur at 20% opacity, where a palette colour reads as dirt.
    shadow = libSelf.color.mkColor [
      0
      0
      0
    ];

    inherit accent;
    accentAlt = palette.base0C;

    negative = palette.base08;
    positive = palette.base0B;
    info = palette.base0D;
    neutral = palette.base09;
  };

  colors = lib.mapAttrs (_: hex) (defaults // slots);

  themeName = "Breeze-${builtins.replaceStrings [ " " ] [ "-" ] scheme.name}";
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
      ${pkgs.writers.writeJSON "colors.json" colors} \
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
    description = "Breeze cursors recoloured for ${scheme.name}";
    license = lib.licenses.lgpl3Plus;
  };
}
