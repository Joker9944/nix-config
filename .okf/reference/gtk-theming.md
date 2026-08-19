---
type: Reference
title: GTK theming and adw-gtk3
description: Why the stock GTK stylesheets cannot be recoloured and adw-gtk3 is therefore mandatory, which toolkits actually need it, and why `gtk.gtk4.theme` is the wrong lever for GTK4.
resource: https://github.com/lassekongo83/adw-gtk3
tags: [reference, gtk, libadwaita, adw-gtk3, nix-schemes, theming]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-19T00:00:00Z
---

# Why the theme is mandatory

The stock stylesheets are compiled flat. GTK3's built-in Adwaita declares 36 `@define-color` names
and references them **zero** times; GTK4's built-in `Default` does the same. Sass resolved every
`darken()` / `mix()` at build time, so those names survive only as an API for third-party app CSS —
the stylesheet itself never reads them. Overriding them from `extraCss` changes nothing.

adw-gtk3 is generated from libadwaita's stylesheet, which keeps `mix()` / `alpha()` as *runtime* CSS
functions over the named colours — its GTK3 sheet references `@window_bg_color` 228× and
`@accent_bg_color` 176×. That propagation is the only reason `mkGtk3ExtraCss` and `mkGtk4ExtraCss`
have anything to bind to, so the dependency cannot be dropped for a pure-`extraCss` approach.

# Who needs it

| Consumer | Toolkit | Needs adw-gtk3 |
|---|---|---|
| `inkscape`, `meld`, `librewolf` | GTK3 | yes — nothing else is overridable |
| `regreet` | GTK4, **no libadwaita** in its `buildInputs` | yes — otherwise fully unthemed |
| Electron / Chromium | GTK4, no libadwaita | yes |
| `yas`, GNOME apps, portals | GTK4 + libadwaita | no — libadwaita bridges `@define-color` → `--var` itself |

libadwaita apps ignore `gtk-theme-name` by design, and the theme agrees: `libadwaita-tweaks.css`
opens with *"These fixes are not for libadwaita apps."*

# Applying it to GTK4

`gtk.gtk4.theme` does not put the theme on GTK4's search path. It triggers a home-manager workaround
that `@import`s the theme into `~/.config/gtk-4.0/gtk.css` — the *user* stylesheet, the one channel
libadwaita apps cannot opt out of. Name the theme directly instead:

```nix
gtk4 = {
  theme = null;
  extraConfig.gtk-theme-name = themeName;
};
```

`theme = null` on its own is a trap: `mkGtkSettings` emits `gtk-theme-name` only when `theme != null`,
so dropping it without `extraConfig` un-themes every non-libadwaita GTK4 app. The package still
reaches the profile — and thus `XDG_DATA_DIRS` — through `gtk.theme` for GTK 2/3.

# The `:root` block

`mkGtk4ExtraCss`'s `:root` block looks redundant under libadwaita, which already bridges every named
colour to its custom property. It is not: the template is shared with `modules/nixos/regreet.nix`,
and regreet has no libadwaita to do that bridging. Do not trim it.

# Related

* [/reference/base24.md](/reference/base24.md) — which palette slot each of these colours comes from.
* [/workflows/lookup-hm-option.md](/workflows/lookup-hm-option.md) — checking option shape against the
  pinned revision, which is how the `mkGtkSettings` behaviour above was established.
