---
type: Reference
title: Discord theming through Vencord
description: Discord declares colour in two layers — primitive HSL ramps under semantic tokens — and only the ramps are worth overriding; plus how a stylesheet reaches Vesktop.
resource: https://docs.betterdiscord.app/discord/variables
tags: [reference, discord, vesktop, vencord, css, theming]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-01T00:00:00Z
---

# Two layers, and only the lower one is worth overriding

Discord declares colour twice. At `:root` sit eleven primitive ramps — `primary`, `brand`, `red`,
`green`, `yellow`, `orange`, `blue`, `teal`, `white`, `black` and `dontuse` — of about 26 steps
each, every step a bare HSL triplet with an `hsl()` companion:

```css
--primary-600-hsl: 223 calc(var(--saturation-factor, 1)*6.7%) 20.6%;
--primary-600:     hsl(var(--primary-600-hsl)/1);
```

Above them, `.theme-dark` and `.theme-light` define 262 semantic tokens each, `.theme-darker` and
`.theme-amoled` 176 each. None holds a colour; each references a ramp step, 62 of the dark ones
through alpha:

```css
--background-primary:           var(--primary-600);
--background-modifier-hover:    hsl(var(--primary-500-hsl)/0.3);
--background-modifier-selected: hsl(var(--primary-500-hsl)/0.6);
```

Overriding the ramps re-derives every semantic token at once, preserves the alpha that separates
hover from selected from active, and never names a theme class — so polarity, `.theme-darker` and
the visual refresh keep working, and tokens Discord adds later inherit the scheme unasked. The dark
theme reaches only 50 distinct ramp steps, so the surface is small.

Overriding the semantic layer instead flattens the composites to solid colours: hover at 0.3 and
selected at 0.6 over the same step collapse into one value and the states stop being
distinguishable. That is a property of the layer, not of any particular mapping.

# Reading a ramp

The step number is a lightness scale, not an index: it runs `100` (lightest) to `900` (darkest),
monotonically. `--primary-100` is 97.6% lightness, `--primary-900` is 0.8%.

The numbering is generated rather than arbitrary, so it needs no table. Every named ramp carries `H`,
`H+30` and `H+60` for the hundreds 100 to 800, plus `900` and the one irregular `345` — 26 steps.
`primary` adds `645`, for 27.

`--dontuse-*` is a legacy grey ramp whose name is a lie — the theme blocks reference it 132 times.
It is indexed `0` to `26` rather than numbered, which is exactly the length of `primary`, and its
steps overlap where they coincide: `--dontuse-1-hsl` is byte-identical to `--primary-130-hsl`. Drive
it from the same greys, positionally.

The value must be a bare `H S% L%` triple with no `hsl()` wrapper, because consumers compose it as
`hsl(var(--x-hsl)/<alpha>)`. The `calc(var(--saturation-factor, 1)*S%)` form carries the client's
saturation control through to the theme; writing a plain percentage hard-codes saturation and the
control stops reaching anything.

# Where a base24 palette lands

Discord's dark hierarchy runs the opposite direction to base24's. `--background-primary` is
`--primary-600` at 20.6% lightness, and `--background-secondary` (`630`, 18%) and
`--background-tertiary` (`700`, 12.5%) are *darker* than it, where base01 and base02 are lighter
than base00. The steps lighter than the background — `560` (23.5%), `530`, `500` (32.5%) — are what
base01 and base02 correspond to, and the nine steps below `600` map onto base10/base11 and
extrapolation past them.

The load-bearing anchors in `.theme-dark`, by how much of the UI hangs off them:

| step | carries |
|---|---|
| `primary-500` | every `--background-modifier-*` and `--bg-mod-*`, as the alpha base |
| `primary-600` | `--background-primary`, `--bg-base-primary`, `--bg-surface-raised` |
| `primary-630` | `--background-secondary`, `--bg-base-secondary`, `--background-nested-floating` |
| `primary-660` | `--background-secondary-alt`, `--bg-base-tertiary` |
| `primary-700` | `--background-tertiary`, `--activity-card-background` |
| `primary-800` | `--background-floating`, `--bg-surface-overlay` |
| `primary-230` | `--text-normal`, `--text-primary`, `--interactive-hover` |
| `primary-330` | `--text-secondary`, `--header-secondary`, `--interactive-normal` |
| `primary-360` | `--text-muted`, `--channels-default` |
| `white-500` | `--interactive-active`, and 43 alpha overlays for borders and ripples |

`--text-link` is `--blue-345`, not a brand step.

# Selectors are the fragile layer

Anything below the ramps means selecting elements, and Discord's class names are
`readableName__hash`. The hash regenerates on naming conflicts and large UI changes, silently.
BetterDiscord's guidance is to prefer `[class*=]` attribute matching, which tolerates the rotation,
and to anchor on DOM structure — `:nth-child()`, `:has()`, `:is()`, `:where()` — when classes are
absent. Rules keyed to a literal Discord brand hex (`path[fill^="rgb(88,101,242)"]`) rot the same
way. Vencord's ThemeAttributes plugin adds stable `data-*` attributes for exactly this reason.

# Fonts are not reachable from `:root` alone

`--font-primary`, `--font-display`, `--font-headline` and `--font-code` are declared at `:root` and
then redeclared under `:root:lang(bg)`, `:lang(el)`, `:lang(ru)`, `:lang(uk)`, `:lang(ko)`,
`:lang(ja)`, `:lang(zh-CN)` and `:lang(zh-TW)`. Those are more specific, so a plain `:root`
override wins on English and silently loses on eight locales.

# How a stylesheet reaches Vesktop

`programs.vesktop` and `programs.equibop` are one home-manager module generated twice by
`modules/programs/vesktop/mkVesktopLikeModule.nix`, differing only in whether the inner namespace is
`vencord` or `equicord`. Both expose three sinks, all written through `home.file` and therefore
read-only store symlinks:

* `<cord>.themes.<name>` → `themes/<name>.css`, enabled by naming `"<name>.css"` in
  `<cord>.settings.enabledThemes`.
* `<cord>.extraQuickCss` → `settings/quickCss.css`, applied whenever the client's `useQuickCss` is
  set, with no enable list.
* `<cord>.settings` → `settings/settings.json`.

Declaring `settings` freezes the client's entire runtime state — Vencord writes an explicit
`enabled` flag for every plugin whether or not it was touched, so the file is over 12 KB of mostly
defaults, and the UI can no longer persist a change to any of it. There is no mutable-copy option:
`modules/lib/file-type.nix` offers `text`, `source`, `recursive` and `force`, all symlinks.

Vencord appends a `<vencord-root>` element to `document.documentElement` holding core, managed and
user style nodes in that order (`src/api/Styles.ts`), which puts everything it injects after
Discord's own `<head>` stylesheets — so a `:root` override wins on source order at equal
specificity, with no `!important`. Within the user node, `DOMContentLoaded` creates `vencord-themes`
before `vencord-custom-css`, so QuickCSS also outranks the theme files.

Enabled themes are not inlined. The node holds one `@import url("vencord:///themes/<name>.css?v=<ts>")`
per theme, cache-busted with a timestamp. QuickCSS is switched by setting `disabled` on its style
element rather than by removing it, so `useQuickCss` gates it at runtime.

# Related

* [/reference/base24.md](/reference/base24.md) — the palette whose slots the ramps have to absorb.
* [/decisions/scheme-model.md](/decisions/scheme-model.md) — how a scheme's slots are declared.
