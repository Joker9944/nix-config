/**
  Build a scheme from a source palette of hex strings.

  The result is total: a base16 source is upcast to 24 slots first, so every view is
  present for every scheme and a consumer never branches on which system it came from.

  # Type

  ```
  mkScheme :: { source, overrides ? { }, lightenWeight ? 0.2 } -> scheme
  ```

  # Arguments

  - `source`: `{ name, author, variant, palette }`, the palette a map of hex strings
  - `accent`: the color consumers reach for when they need one that is not a background
    or a foreground
  - `overrides`: colors replacing what a view derived, keyed by the same path. A value is
    either a palette slot name or a hex string.
  - `lightenWeight`: passed to `color.upcastPalette`

  # Example

  ```nix
  mkScheme {
    source = generateScheme "base24" "dracula";
    overrides.ansi."0" = "base01";
  }
  => { meta = { system = "base24"; name = "Dracula"; … }; palette = { … }; named = { … }; … }
  ```
*/
{
  lib,
  libSelf,
  libUtil,
  ...
}:
{
  source,
  accent ? "base0D",
  overrides ? { },
  lightenWeight ? 0.2,
}:
let
  sourcePalette = lib.mapAttrs (
    _: hex: libSelf.color.mkColor (libSelf.color.fromHex hex)
  ) source.palette;

  # A value naming a palette slot resolves to it; anything else is parsed as hex. Palette
  # overrides name a *source* slot, so overriding one cannot depend on overriding another.
  resolve =
    resolvePalette: value:
    resolvePalette.${value} or (libSelf.color.mkColor (libSelf.color.fromHex value));

  # Overriding precedes the upcast, so a slot derived from an overridden one follows it.
  finalPalette = libSelf.color.upcastPalette { inherit lightenWeight; } (
    sourcePalette // lib.mapAttrs (_: resolve sourcePalette) (overrides.palette or { })
  );

  updates = lib.collect (update: update ? path) (
    lib.mapAttrsRecursive (path: value: {
      inherit path;
      update = _: resolve finalPalette value;
    }) (lib.removeAttrs overrides [ "palette" ])
  );
in
lib.updateManyAttrsByPath updates {
  meta = {
    system = "base24";
    inherit (source) name author variant;

    # A tinted source always carries one; `source.custom` declares no slug option, so a
    # hand-written scheme derives its own.
    slug = source.slug or (libUtil.strings.slugify source.name);
  };

  palette = finalPalette;
  accent = resolve finalPalette accent;

  named = libSelf.views.named finalPalette;
  status = libSelf.views.status finalPalette;
  ansi = libSelf.views.ansi finalPalette;
}
