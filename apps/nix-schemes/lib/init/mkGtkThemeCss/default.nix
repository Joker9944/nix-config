/**
  Compile the GTK stylesheets for a scheme into a directory holding `gtk3.css`
  and `gtk4.css`. Requires pkgs (impure).

  Nix resolves every colour to a literal and writes `_palette.scss`; the SCSS
  under `scss/` owns structure only. `gtkcolor` and `gtkalpha` come from the
  `adw-colors` input rather than being reimplemented — sass cannot express a
  bare `@name` or GTK's two-argument `alpha()`.

  # Type

  ```
  mkGtkThemeCss :: { scheme, accents, accent? } -> derivation
  ```

  # Arguments

  - `scheme`: Color scheme with palette and variant
  - `accents`: Accent color map (from mkAccentsFromPalette or mkAccentsFromColor)
  - `accent`: Which accent to use (default: "blue")

  # Example

  ```nix
  mkGtkThemeCss {
    inherit scheme;
    accents = gtk.mkAccentsFromPalette scheme.palette;
    accent = "purple";
  }
  ```
*/
{
  inputs,
  libSelf,
  lib,
  pkgs,
  ...
}:
{
  scheme,
  accents,
  accent ? "blue",
}:
let
  inherit (scheme) palette;

  # Foregrounds sit on saturated fills, so they follow whichever end of the
  # palette contrasts better against the fill rather than against the window.
  pickFg =
    color:
    if
      libSelf.color.contrastRatio color palette.base00 > libSelf.color.contrastRatio color palette.base05
    then
      palette.base00
    else
      palette.base05;

  colors = {
    window_bg = palette.base00;
    window_fg = palette.base05;
    view_bg = palette.base00;
    view_fg = palette.base05;
    surface_bg = palette.base01;

    accent_bg = accents.${accent};
    accent_fg = pickFg accents.${accent};

    destructive_bg = palette.base08;
    destructive_fg = pickFg palette.base08;
    success_bg = palette.base0B;
    success_fg = pickFg palette.base0B;
    warning_bg = palette.base09;
    warning_fg = pickFg palette.base09;

    # adw-colors' $wm_border / $wm_border_backdrop: 18% and 5% white over the
    # window background.
    wm_border = libSelf.color.lighten palette.base00 0.18;
    wm_border_backdrop = libSelf.color.lighten palette.base00 0.05;
  }
  // lib.mapAttrs' (name: lib.nameValuePair "accent_${name}") accents;
in
pkgs.stdenv.mkDerivation (finalAttrs: {
  name = "adw-${scheme.meta.name}";

  inherit (scheme.meta) variant;

  src = ./scss;
  dontUnpack = true;

  passthru.sassLoadPaths = [
    "${inputs.adw-colors}/src/sass"
    (lib.pipe colors [
      (lib.mapAttrsToList (name: color: "\$${name}: #${color.hex};"))
      (lib.concatStringsSep "\n")
      (pkgs.writeTextDir "settings/_palette.scss")
    ])
  ];

  SASS_PATH = lib.concatMapStringsSep ":" (p: "${p}") finalAttrs.passthru.sassLoadPaths;

  nativeBuildInputs = [ pkgs.dart-sass ];

  preferLocalBuild = true;

  buildPhase = ''
    runHook preBuild

    sass --style=expanded --no-source-map $src/gtk3-${finalAttrs.variant}.scss theme/gtk3.css
    sass --style=expanded --no-source-map $src/gtk4-${finalAttrs.variant}.scss theme/gtk4.css

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp theme/gtk3.css $out
    cp theme/gtk4.css $out

    runHook postInstall
  '';
})
