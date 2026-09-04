---
type: Decision
title: The scheme is a total derived model
description: Every view a consumer reads is computed for every scheme; user input enters as typed options the module system merges, never as post-hoc mutation. Replaces the transformer list, the four override shapes and requireKey.
tags: [decision, nix-schemes, api, colour]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-01T00:00:00Z
---

# The rule

`mkScheme` takes a source palette of hex strings and returns a scheme where `meta`, `palette`,
`accent`, `named`, `status` and `ansi` are all present, always. A base16 source is upcast to 24 slots
first ([color/upcastPalette.nix](/reference/base24.md)), so `meta.system` is provenance and never
something to branch on. `overrides.palette` lands on the source *before* that upcast, so a slot
derived from an overridden one follows it; the view overrides land after.

`meta.slug` names the cursor theme directory and the vicinae theme key, so it has to be exact. A
tinted source takes the vendored `slug` and falls back to the filename; a custom one derives it with
`libUtil.strings.slugify`. Deriving it for tinted would be wrong, not merely risky — 28 of the 35
stated slugs are editorial (`Blue Forest` → `blueforest`, `Heetch Dark` → `heetch`) and no rule
recovers them.

Colour flows one way — source → scheme → consumer. Nothing writes back into a scheme after it is
built.

# Where a colour is declared

The scheme model holds only what is derivable from the palette **and** meaningful to more than one
consumer. Everything else is an option on the consumer module, defaulted from the scheme. The test is
*would a user set this once and have it apply everywhere?* — `accent` yes, the cursor theme's
`accentAlt` no. A colour moves into the model when a **second** consumer needs it; that move is
mechanical, so guessing wrong the first time is cheap.

# The consumer's override channel

Each renderer module has exactly one, decided by where its output lands:

| Output | Channel |
|---|---|
| a derivation, few slots — `schemes.cursors` | `colors`, one declared option per slot |
| a derivation, many slots — `schemes.vscode` | `colors`, one free-form `attrsOf str` merged over the generated set |
| a mergeable option — `schemes.vicinae`, `schemes.kitty` | `settings`, or the app's own option |
| a mergeable option over a foreign vocabulary — `schemes.librewolf`, `schemes.spicetify`, `schemes.vesktop` | `colors`, one declared option per slot |

A derivation has no downstream merge point, so the module must own its slots; where one exists it
*is* the channel, and mirroring its keys as options would be duplicated surface — unless the keys
are a closed vocabulary somebody else owns. `schemes.librewolf` writes into a free-form attrset yet
declares all 37 of them, because [FirefoxColor](/reference/firefox-theming.md) drops an unknown key
in silence and substitutes its own default for a missing one; typed options make both an eval error.
`schemes.spicetify` declares its 18 for the same reason — spicetify's `BaseColorList` is the closed
set, and an omitted key falls back to spicetify's stock dark rather than to the theme.
`schemes.vesktop` declares 18 for a different reason: its merge point is `types.lines` CSS, so
overriding through the channel means writing rules that redefine what the module just emitted. A
mergeable *text* channel is not a usable override channel.
Declaring stops paying once the slots outrun the descriptions — `schemes.vscode` writes 365
workbench keys that nobody would enumerate, so its `colors` is one free-form option and
`tokenColors` an appended list. `schemes.vesktop` sits under that line by anchoring 18 of Discord's
~290 ramp steps and interpolating the rest, which are not options.

Both rows name a family rather than a module: `mkVariantModules` generates three browsers and four
editors from one template each, so the channel is chosen once and inherited by every variant.

# What this replaced

`schemes.transformers` (an ordered list of `scheme -> libSchemes -> attrs` folded with
`recursiveUpdate`), the `transform` method on the scheme value, `schemes.gtk.accentTransformer`, four
incompatible per-consumer override shapes, and `requireKey`. Per-scheme deviation is now
`schemes.overrides.<view>.<path>`, typed and merged by the module system, so ordering is no longer
the caller's problem.

# Trade-offs accepted

* **A base16 scheme silently gains eight derived colours.** The alternative — a fallback accessor —
  keeps the palette honest but leaves every consumer on a fallback path.
* **No function-shaped escape hatch.** Anything the override tree cannot express is a signal the
  model is wrong. One can be added later; removing one that themes depend on cannot.
* **`schemes.accent` defaults to `base0D`, not to the GTK accent selector.** `custom.theme.gtk.accent`
  used to double as the palette selector; a theme that wants that slot now names it
  (`modules/theme/uwunicorn.nix` sets `accent = "base0E"`).

# Related

* [/architecture/custom-lib.md](/architecture/custom-lib.md) — where `mkScheme` and the views sit.
* [/reference/base24.md](/reference/base24.md) — the slot table the views map.
