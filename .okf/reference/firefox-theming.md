---
type: Reference
title: Firefox static themes and the sideload update trap
description: Why the librewolf theme is an unsigned static WebExtension, the two facts about Firefox's sideload change detection that stop an installed theme from ever updating, and why activeThemeID cannot be set as a pref.
resource: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/theme
tags: [reference, firefox, librewolf, webextension, nix-schemes, theming]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-01T00:00:00Z
---

# The theme is a static WebExtension

`schemes.librewolf` builds a manifest-v2 extension whose only content is `theme.colors` plus
`theme.properties.color_scheme`, zips it, and installs it through
`programs.librewolf.profiles.<name>.extensions.packages`. Firefox's own theme engine renders it —
nothing runs at page load.

The xpi is unsigned, so it installs only because LibreWolf builds with addon signature checking off
(`lib/librewolf/mozilla.cfg`). That is why the consumer is `schemes.librewolf` and there is no
`schemes.firefox`: on a stock build the same xpi is rejected.

`color_scheme` comes from `meta.variant`. Without it Firefox guesses the toolbar's polarity from the
toolbar colour (`LightweightThemeConsumer._isToolbarDark`), and the guess also drives the content
area's colour scheme.

# An installed theme never updates

Change detection for a sideloaded addon is one line, `XPIProvider.sys.mjs`:

```js
addonChanged = xpiState.getModTime(entry) || entry.path != xpiState.path;
```

Both terms are constant under Nix:

* `readAddons` resolves the profile symlink only when the leafname equals the bare addon ID, and
  then only to a directory. A `<id>.xpi` link is used as-is, so `entry.path` stays the profile path.
* `getModTime` stats through the link into the store, where every mtime is normalised to 1. The
  profile's `extensions.json` records `"updateDate": 1000` permanently.

So the manifest is read once, at first install, and never again — a scheme change rebuilds the xpi
but the browser keeps the colours it first saw. Bumping the manifest `version` does not help;
Firefox never opens the file to see it. Breaking the tie needs the profile entry's *path* or *mtime*
to change, which no arrangement of `extensions.packages` produces.

# Two related dead ends

* A sideloaded addon lands `userDisabled` when `location.scope & extensions.autoDisableScopes`
  (`XPIDatabase.sys.mjs`). `SCOPES_SIDELOAD` is `SCOPE_PROFILE` and the pref defaults to 15.
* `extensions.activeThemeID` is *written* by `XPIDatabase.addonChanged()`, not read as authority.
  Setting it through `programs.librewolf.profiles.<name>.settings` selects nothing; the authority is
  `userDisabled` on the theme addon.

# Related

* [/decisions/scheme-model.md](/decisions/scheme-model.md) — where the colour slots are declared.
* [/reference/base24.md](/reference/base24.md) — the palette the slots map.
