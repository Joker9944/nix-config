---
type: Reference
title: base16 / base24 palette slots
description: Slot meanings for base00–base17, the five ANSI assignments where base16 and base24 disagree, and which of the two each consumer in this repo follows.
resource: https://github.com/Base24/base24/blob/master/styling.md
tags: [reference, colour, base16, base24, nix-schemes, theming]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-19T00:00:00Z
sources:
  - id: base24-styling
    resource: https://raw.githubusercontent.com/Base24/base24/master/styling.md
    title: base24 styling specification
  - id: base16-styling
    resource: https://raw.githubusercontent.com/tinted-theming/home/main/styling.md
    title: tinted-theming base16 styling guidelines
---

# Slots

Two specs describe the same slots and **assign different ANSI numbers to five of them**. Both columns
below are verbatim.[^base24-styling][^base16-styling] Names in parentheses mark a slot with no
identified terminal use — a generic colour description, per base24's own footnote.

| Slot | Editor role | b24 ANSI | b24 name | b16 ANSI | b16 name |
|---|---|---|---|---|---|
| `base00` | Default Background | — | Background | **0** | Black (Background) |
| `base01` | Lighter Background (status bars) | **0** | Black | 18 | (Darkest Gray) |
| `base02` | Selection Background | **8** | Bright Black | 19 | (Dark Gray) |
| `base03` | Comments, Invisibles, Line Highlighting | — | (Grey) | **8** | Bright Black (Gray) |
| `base04` | Dark Foreground (status bars) | — | (Light Grey) | 20 | (Light Gray) |
| `base05` | Default Foreground, Caret, Delimiters, Operators | — | Foreground | **7** | White |
| `base06` | Light Foreground | **7** | White | 21 | (Lighter White) |
| `base07` | Lightest Foreground | 15 | Bright White | 15 | Bright White |
| `base08` | Variables, XML Tags, Markup Link Text | 1 | Red | 1 and 9 | Red and Bright Red |
| `base09` | Integers, Boolean, Constants, XML Attributes | **3** | Yellow | 16 | (Orange) |
| `base0A` | Classes, Markup Bold, Search Text Background | ~11 | (Bright Yellow) | **3** and 11 | Yellow and Bright Yellow |
| `base0B` | Strings, Inherited Class, Markup Code | 2 | Green | 2 and 10 | Green and Bright Green |
| `base0C` | Support, Regular Expressions, Escape Characters | 6 | Cyan | 6 and 14 | Cyan and Bright Cyan |
| `base0D` | Functions, Methods, Attribute IDs, Headings | 4 | Blue | 4 and 12 | Blue and Bright Blue |
| `base0E` | Keywords, Storage, Selector, Markup Italic | 5 | Purple | 5 and 13 | Magenta and Bright Magenta |
| `base0F` | Deprecated Highlighting, embedded language tags | — | (Dark Red/Brown) | 17 | (Dark Red or Brown) |
| `base10` | Darker Background | — | ('Darker' Black) | — | — |
| `base11` | Darkest Background | — | ('Darkest' Black) | — | — |
| `base12` | — | 9 | Bright Red | — | — |
| `base13` | — | 11 | Bright Yellow | — | — |
| `base14` | — | 10 | Bright Green | — | — |
| `base15` | — | 14 | Bright Cyan | — | — |
| `base16` | — | 12 | Bright Blue | — | — |
| `base17` | — | 13 | Bright Purple | — | — |

The two specs also differ in shape: base16 has no separate bright slots, so `base08`–`base0E` each
serve both the normal and bright ANSI number. base24 adds `base10`–`base17` and splits them.

## Why base16 uses numbers above 15

ANSI proper is 0–15; 16–21 are the bottom of the xterm-256color palette. base16 has to reach there
because only ten of its slots fit in 0–15 — with 9–14 repeating the hues of 1–6, ten slots already
cover all sixteen positions. The six left over (`base01`, `base02`, `base04`, `base06`, `base09`,
`base0F`) get parked at 16–21, and the spec warns those may silently not apply, since not every
terminal accepts extended colours.[^base16-styling]

base24 exists to fix this: with `base10`–`base17` supplying real brights and darks, every base24
ANSI number in the table above lands within 0–15. That is also why the five disagreements exist —
base24 rebuilt the mapping once it had enough slots to do it without a workaround.

# The five disagreements

| ANSI | base16 says | base24 says |
|---|---|---|
| 0 (black) | `base00` | `base01` |
| 3 (yellow) | `base0A` | `base09` |
| 7 (white) | `base05` | `base06` |
| 8 (bright black) | `base03` | `base02` |
| 15 | `base07` | `base07` — agree |

base24 shifts the dark end up by one slot (background stops being ANSI black) and reassigns ANSI 3
from yellow to `base09`, which base16 calls orange. **Neither is wrong; they are different
vocabularies.** Getting this backwards is the recurring failure — a name like "yellow" resolves to
`base09` or `base0A` depending entirely on which spec is in force.

`base09` and `base0A` are also where a colour *name* and an ANSI *slot* come apart: base16 calls
`base09` orange but base24 hands it ANSI's yellow, because ANSI has no orange (base16 parks orange
at the extended 16). A UI accent labelled "orange" wants `base09` under either spec; a terminal's
yellow wants whichever the scheme's system says.

## base24 fallbacks

base24 states the base16 slot each of its new slots falls back to — so this is spec, not inference:

`base10`,`base11`→`base00` · `base12`→`base08` · `base13`→`base0A` · `base14`→`base0B` ·
`base15`→`base0C` · `base16`→`base0D` · `base17`→`base0E`

Note `base13` falls back to `base0A`, **not** to the `base09` it shares an ANSI number with. A
dull/bright pair that shifts hue is the symptom of having crossed the two vocabularies.

# Which vocabulary each consumer follows

| File | Follows |
|---|---|
| `apps/nix-schemes/lib/transformers/ansi.nix` | base24 — `"0" = base01`, `"3" = base09`, `"7" = base06`, `"8" = base02` |
| `apps/nix-schemes/lib/transformers/named.nix` | base24 ANSI, despite colour-word attribute names; shape is 8 colours × `dull`/`bright` |
| `apps/nix-schemes/lib/gtk/mkAccentsFromPalette.nix` | base24 — `yellow = base09`; no orange slot, so derives one as `base08.mix base09 0.5` |
| `apps/nix-schemes/modules/home/vicinae.nix` | base16 colour names — `orange = base09`, `yellow = base0A` |
| `apps/nix-schemes/modules/home/kitty.nix` | base24 — reads the scheme's `ansi` for `color0`–`color15` rather than naming colours itself |

`named.nix` is the one to read twice: its attributes look like colour names but the framing is ANSI,
so `yellow.dull = base09` is correct there and would be wrong in a UI accent block.

`modules/global/theme/orchidlift/default.nix` overrides ANSI `0`, `3`, `7` and `8` — which is
exactly the four slots above where the specs disagree. It is not an arbitrary tweak: it runs base24
schemes on base16's ANSI table. The override produces `ansi.*` only, so `named.*` keeps base24's
assignment and the two disagree on those four slots by construction.

# Related

* [/architecture/custom-lib.md](/architecture/custom-lib.md) — how `libSchemes` and its transformers
  load.

[^base24-styling]: base24 styling specification
[^base16-styling]: tinted-theming base16 styling guidelines
