---
type: Reference
title: Firefox theming through FirefoxColor
description: How schemes.librewolf writes its palette into the FirefoxColor extension's storage.local, the profile-wide storage backend that costs, and why the static theme xpi it replaced could never update.
resource: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/theme
tags: [reference, firefox, librewolf, webextension, nix-schemes, theming]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-01T00:00:00Z
verified:
  - by: human:joker9944
    at: 2026-09-01T00:00:00Z
---

# The theme lives in extension storage

`schemes.firefox`, `schemes.librewolf` and `schemes.floorp` are one template generated per variant
(`modules/home/firefox.nix`, see [/architecture/custom-lib.md](/architecture/custom-lib.md)). Each
installs [FirefoxColor](https://addons.mozilla.org/firefox/addon/firefox-color/) through
`programs.<variant>.policies.ExtensionSettings` — `force_installed` against an AMO `install_url`, the
pattern the 1Password mixin already uses — and writes the palette into its `storage.local` through
`programs.<variant>.profiles.<name>.extensions.settings`. Being AMO-signed is what lets the same
template serve stock Firefox; the xpi it replaced needed LibreWolf's disabled signature checking.

The extension's `init()` runs at every browser start: with `firstRunDone` set it reads `theme` from
storage and calls `browser.theme.update()`. Home-manager rewrites that file on every activation, so
a scheme change reaches the chrome on the next restart.

Colours must be `{ r, g, b }` integers. FirefoxColor spreads its input into an object before handing
it to tinycolor, so a hex string decomposes into `{ 0 = "#"; 1 = "f"; … }` and renders black.

`theme.properties` is unreachable — FirefoxColor rebuilds it from background alignment and tiling
alone, so `color_scheme` cannot be passed and Firefox falls back to guessing toolbar polarity with
`LightweightThemeConsumer._isToolbarDark`. `browser.theme.toolbar-theme` and
`browser.theme.content-theme` are the levers when it guesses wrong.

# What this costs

Home-manager sets `extensions.webextensions.ExtensionStorageIDB.enabled = false` for the whole
profile whenever `extensions.settings` is non-empty, which is what keeps the JSON backend readable.
`ExtensionStorageIDB.selectBackend` consults only that pref, never `isMigratedExtension`, so *every*
extension in the profile drops back to the JSON backend — where an already-migrated one finds
nothing, because `migrateJSONFileData` deletes the JSON file after importing it. The data survives
in `storage/default/moz-extension+++<uuid>/` and returns if the pref is flipped back.

Home-manager links `storage.js` into the store, but Firefox's JSONFile backend saves by atomic
rename, so the extension replaces that link with a regular file on its first write — it stores an
empty `images` map at startup. `extensions.settings.<id>.force` is required on every activation, not
just the first.

# Why not a static theme xpi

The previous renderer built an unsigned manifest-v2 theme and sideloaded it through
`extensions.packages`. It rendered correctly and could never update, because sideload change
detection is one line in `XPIProvider.sys.mjs`:

```js
addonChanged = xpiState.getModTime(entry) || entry.path != xpiState.path;
```

`readAddons` resolves a profile symlink only when the leafname equals the bare addon ID and the
target is a directory, so an `<id>.xpi` link keeps the profile path; `getModTime` stats through the
link into the store, where mtimes are normalised to 1. Both terms constant, so the manifest is read
once, at first install — and bumping its `version` changes nothing, since Firefox never opens the
file to see it. A sideload also lands `userDisabled` when
`location.scope & extensions.autoDisableScopes` (`SCOPES_SIDELOAD` is `SCOPE_PROFILE`, pref default
15); a policy install is exempt.

# Related

* [/decisions/scheme-model.md](/decisions/scheme-model.md) — where the colour slots are declared.
* [/reference/base24.md](/reference/base24.md) — the palette the slots map.
