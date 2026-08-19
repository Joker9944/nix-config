---
type: Reference
title: base16 / base24 palette slots
description: Slot meanings and ANSI numbers for base00–base17, why base24 is a superset of base16 rather than a rival mapping, and which slots each consumer in this repo reads.
resource: https://github.com/tinted-theming/base24/blob/main/styling.md
tags: [reference, colour, base16, base24, nix-schemes, theming]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-19T00:00:00Z
sources:
  - id: base24-styling
    resource: https://raw.githubusercontent.com/tinted-theming/base24/refs/heads/main/styling.md
    title: base24 styling specification (tinted-theming, v0.1.3)
  - id: base16-styling
    resource: https://raw.githubusercontent.com/tinted-theming/home/main/styling.md
    title: tinted-theming base16 styling guidelines
---

# Which spec

The authority is **tinted-theming/base24**.[^base24-styling] `Base24/base24` is an out-of-date fork
whose ANSI table disagrees with it in four slots; do not cite it. The `schemes` flake input is
`tinted-theming/schemes`, so the tinted-theming spec is the one our data is built to.

# Slots

Names in parentheses mark a slot with no identified terminal use — a generic colour description, per
the spec's own footnote.

| Slot | ANSI | Terminal | Editor role |
|---|---|---|---|
| `base00` | **0** | Black (Background) | Default Background |
| `base01` | 18 | (Darkest Gray) | Lighter Background (status bars) |
| `base02` | 19 | (Dark Gray) | Selection Background |
| `base03` | **8** | Bright Black (Gray) | Comments, Invisibles, Line Highlighting |
| `base04` | 20 | (Light Gray) | Dark Foreground (status bars) |
| `base05` | **7** | White | Default Foreground, Caret, Delimiters, Operators |
| `base06` | 21 | (Lighter White) | Light Foreground |
| `base07` | 15 | Bright White | Lightest Foreground |
| `base08` | 1 | Red | Variables, XML Tags, Markup Link Text, Diff Deleted |
| `base09` | 16 | (Orange) | Integers, Boolean, Constants, XML Attributes |
| `base0A` | **3** | Yellow | Classes, Markup Bold, Search Text Background |
| `base0B` | 2 | Green | Strings, Inherited Class, Markup Code, Diff Inserted |
| `base0C` | 6 | Cyan | Support, Regular Expressions, Escape Characters |
| `base0D` | 4 | Blue | Functions, Methods, Attribute IDs, Headings |
| `base0E` | 5 | Magenta | Keywords, Storage, Selector, Markup Italic |
| `base0F` | 17 | (Dark Red or Brown) | Deprecated Highlighting, embedded language tags |
| `base10` | — | (Darker Black) | Darker Background |
| `base11` | — | (Darkest Black) | Darkest Background |
| `base12` | 9 | Bright Red | — |
| `base13` | 11 | Bright Yellow | — |
| `base14` | 10 | Bright Green | — |
| `base15` | 14 | Bright Cyan | — |
| `base16` | 12 | Bright Blue | — |
| `base17` | 13 | Bright Magenta | — |

**base24 is a superset of base16, not a rival vocabulary.** No slot moves between them: every ANSI
number base24 gives a slot, base16 gives it too. The one asymmetry is at the bright end — base16 has
nothing to put at 9–14, so it doubles `base08`–`base0E` onto those numbers as well (its table reads
"1 and 9", "3 and 11", …), while base24 frees them by adding `base12`–`base17`. A colour name means
the same thing under either system, so no consumer needs to know which spec is in force to resolve
one.

## Why base16 uses numbers above 15

ANSI proper is 0–15, and only ten base16 slots fit there — with 9–14 repeating the hues of 1–6, ten
slots already cover all sixteen positions. The six left over (`base01`, `base02`, `base04`, `base06`,
`base09`, `base0F`) are parked at 16–21, the bottom of the xterm-256color palette, and the spec warns
those may silently not apply since not every terminal accepts extended colours.[^base16-styling]

base24 exists to fix this: `base12`–`base17` supply real brights, so every ANSI number 0–15 lands on
its own slot.

## base16 fallbacks

The spec states the base16 slot each new slot falls back to:

`base10`,`base11`→`base00` · `base12`→`base08` · `base13`→`base0A` · `base14`→`base0B` ·
`base15`→`base0C` · `base16`→`base0D` · `base17`→`base0E`

Under base16 the bright ANSI numbers therefore repeat their dull counterparts — `9` renders as
`base08`, `11` as `base0A`, and so on. `transformers/interpolateBase24.nix` synthesises the missing
slots when a base16 scheme needs real brights.

# Semantic guidance

Beyond the slot table **base24** names colours for UI states: `base03` marks something inactive,
`base08` errors and alerts, `base0F` warnings, `base0D` focus, `base02` the background of a selected
element with `base05`/`base06` its foreground. base16's document stops after its colour table, so it
carries no equivalent guidance — these names are a base24 addition, not a shared rule.

## Status colours deviate on `warning`

This repo maps status colours to the conventional UI hues instead:

| Status | Slot | |
|---|---|---|
| `info` | `base0D` | blue — matches the spec's focus colour |
| `warning` | `base09` | orange — **deviates**, the spec says `base0F` |
| `error` | `base08` | red — matches the spec's alert colour |
| `success` | `base0B` | green — the spec names no success colour |

`base0F` is "Dark Red or Brown" in the same spec's slot table, close enough to `error`'s red to be
unreadable as a distinct state. The spec's guidance is aimed at text-editor syntax highlighting,
where that reads fine; for UI chrome it does not. `transformers/named.nix` and both adw-gtk3 CSS
templates use the table above.

# Which slots each consumer reads

| File | Reads |
|---|---|
| `apps/nix-schemes/lib/transformers/ansi.nix` | The table above, verbatim — `"0" = base00`, `"3" = base0A`, `"7" = base05`, `"8" = base03` |
| `apps/nix-schemes/lib/transformers/named.nix` | Same table, exposed as colour words × `dull`/`bright`, plus the semantic names |
| `apps/nix-schemes/lib/gtk/mkAccentsFromPalette.nix` | Nine GTK4 accents — `yellow = base0A`, `orange = base09` |
| `apps/nix-schemes/modules/home/vicinae.nix` | Palette slots directly, base24 extras behind its `pick` helper |
| `apps/nix-schemes/modules/home/kitty.nix` | The scheme's `ansi` for `color0`–`color15`, palette slots for chrome |

`modules/global/theme/dracula.nix` overrides ANSI `0` to `base01`: Dracula ships an ANSI black
distinct from its background, and the upstream scheme parks it there. That is a theme deviation, not
a spec disagreement — every other slot derives from the table.

# Related

* [/architecture/custom-lib.md](/architecture/custom-lib.md) — how `libSchemes` and its transformers
  load.

[^base24-styling]: base24 styling specification (tinted-theming, v0.1.3)
[^base16-styling]: tinted-theming base16 styling guidelines
