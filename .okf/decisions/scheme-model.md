---
type: Decision
title: The scheme is a total derived model
description: Every view a consumer reads is computed for every scheme; user input enters as typed options the module system merges, never as post-hoc mutation. Replaces the transformer list, the four override shapes and requireKey.
tags: [decision, nix-schemes, api, colour]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-28T00:00:00Z
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
| a derivation — `schemes.cursors`, `schemes.librewolf` | `colors`, one declared option per slot |
| a mergeable option — `schemes.vicinae`, `schemes.kitty` | `settings`, or the app's own option |

A derivation has no downstream merge point, so the module must own its slots; where one exists it
*is* the channel, and mirroring its keys as options would be duplicated surface.

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
  (`modules/global/theme/uwunicorn.nix` sets `accent = "base0E"`).

# Related

* [/architecture/custom-lib.md](/architecture/custom-lib.md) — where `mkScheme` and the views sit.
* [/reference/base24.md](/reference/base24.md) — the slot table the views map.
