/**
  Recolour an icon theme's Plasma stylesheets against a scheme. Requires pkgs (impure).

  Packs written for Plasma set their colours in `.ColorScheme-*` CSS rules and draw with
  `fill="currentColor"`. Plasma rewrites those rules at load time from the active colour
  scheme; GTK has no such hook and recolours only files *named* `*-symbolic.svg`, so
  everything else renders at whatever the pack baked in. This rewrites the rules at build
  time. Elements are never touched — the vocabulary is already semantic, only the
  stylesheet behind it is wrong.

  The whole `share/icons` tree is copied, not one variant: a variant may symlink into a
  sibling (Colloid-Dark reaches into Colloid-Light for six directories), and those links
  are relative. For the same reason directory names are left alone; the store path is what
  distinguishes the result.

  # Type

  ```
  mkIconTheme :: { scheme, base } -> derivation
  ```

  # Arguments

  - `scheme`: Color scheme with a palette and an `accent` supplied by a transformer
  - `base`: Icon theme package to recolour

  # Example

  ```nix
  mkIconTheme {
    inherit scheme;
    base = pkgs.colloid-icon-theme;
  }
  ```
*/
{
  libSelf,
  pkgs,
  ...
}:
{
  scheme,
  base,
}:
let
  inherit (scheme) palette;

  accent = libSelf.requireKey scheme "accent";

  hex = color: "#${color.hex}";

  # KColorScheme roles, resolved to the same slots mkGtkThemeCss gives their GTK
  # counterparts. The eleven the Plasma docs list, plus four they omit that every
  # surveyed pack uses anyway — Negative/Positive/NeutralText outrank all but Text and
  # Highlight by usage, and breeze-icons is the heaviest user of Accent.
  colors = {
    "ColorScheme-Text" = hex palette.base05;
    "ColorScheme-ViewText" = hex palette.base05;
    "ColorScheme-ButtonText" = hex palette.base05;

    "ColorScheme-Background" = hex palette.base00;
    "ColorScheme-ViewBackground" = hex palette.base00;
    "ColorScheme-ButtonBackground" = hex palette.base01;

    "ColorScheme-Highlight" = hex accent;
    "ColorScheme-Accent" = hex accent;
    "ColorScheme-ViewHover" = hex accent;
    "ColorScheme-ViewFocus" = hex accent;
    "ColorScheme-ButtonHover" = hex accent;
    "ColorScheme-ButtonFocus" = hex accent;

    "ColorScheme-NegativeText" = hex palette.base08;
    "ColorScheme-Error" = hex palette.base08;
    "ColorScheme-PositiveText" = hex palette.base0B;
    "ColorScheme-NeutralText" = hex palette.base09;
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "${base.pname or base.name}-${scheme.name}";

  dontUnpack = true;

  nativeBuildInputs = with pkgs; [
    python3
    gtk3
  ];

  preferLocalBuild = true;

  # Nothing here is an executable, and fixup walks ~30k paths to establish that — two
  # minutes on every palette change.
  dontFixup = true;

  # Not covered by `dontFixup`: gtk3's setup hook registers this as its own post-install
  # phase, and it would delete the caches generated below.
  dontDropIconThemeCache = true;

  buildPhase = ''
    runHook preBuild

    mkdir icons
    # -a keeps the symlinks a pack dedupes with; dereferencing multiplies the tree.
    cp -a ${base}/share/icons/. icons/
    chmod -R u+w icons

    python3 ${./recolour.py} icons ${pkgs.writers.writeJSON "colors.json" colors}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share"
    cp -a icons "$out/share/icons"
    # `cp -a` carried the base package's read-only modes over, and the cache is written
    # into each theme directory.
    chmod -R u+w "$out/share/icons"

    for theme in "$out"/share/icons/*/; do
      # A base theme the pack propagates (hicolor) is a symlink into its own store path:
      # not ours to recolour, and not ours to write a cache into.
      [ -L "''${theme%/}" ] && continue
      [ -f "$theme/index.theme" ] || continue
      # The base theme's cache indexes the colours we just replaced, and a variant may
      # inherit it by symlink.
      rm -f "$theme/icon-theme.cache"
      gtk-update-icon-cache --force --quiet "$theme"
    done

    runHook postInstall
  '';

  meta = base.meta or { };
}
