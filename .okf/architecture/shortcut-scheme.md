---
type: Architecture Pattern
title: Shortcut scheme
description: Modifier ownership per layer — Super to the WM, Ctrl to apps, Ctrl+Shift to the terminal emulator, bare keys to TUIs — and the composition rules a bind in any layer must pass.
tags: [architecture, keybindings, convention]
generated:
  by: claude-code/claude-fable-5
  at: 2026-09-25T00:00:00Z
---

# Every layer owns one modifier space

The split follows the cross-platform consensus in
[/reference/shortcut-standards.md](/reference/shortcut-standards.md): the system owns Super, apps
own Ctrl, terminals sit one modifier up. A bind claims chords only inside its own layer's space, so
no chord changes meaning with focus and no app update can shadow a WM bind.

| Layer | Modifier space |
|---|---|
| WM / global | every chord containing `SUPER`, plus dedicated keys (`XF86*`, `PRINT`) |
| GUI apps | `Ctrl` (+ `Shift` variants) — their platform defaults, left alone |
| Terminal emulator | `Ctrl + Shift` |
| TUIs | bare letters, vim motions, Alt-as-Meta (`ESC`-prefixed), and the `Ctrl` control codes upstream defines |
| Dedicated keys | bare `XF86*` / `PRINT`; a modifier narrows the target, never changes the action |

Three consequences the table implies but that deserve stating:

* The WM never grabs a Super-less chord. Ctrl-anything belongs to whatever has focus, including
  Windows-idiom system chords like Ctrl+Alt+Del.
* Bare `Alt` is conditionally the focused app's: GUIs use it for menu navigation (access keys),
  terminals pass it through as Meta (readline word motions, Emacs `M-`), and an app may claim
  bare-`Alt` chords only where it supports neither. The WM cannot know which case has focus, so
  it never grabs bare Alt — in the scheme Alt appears only glued to Super.
* Prefer the WM's window management over any app's built-in tabs, splits, or layouts, so managing
  windows reads the same regardless of the app.

# Rules that hold in every layer

1. **Earn the chord.** A bind exists only for actions used reflexively, many times a day.
   Anything you'd have to *remember* belongs to the launcher or the app's own palette/search —
   clipboard history, calculator, emoji, power menu. A bind you keep forgetting isn't
   under-advertised, it's mis-assigned: delete it, don't demote it to a rarer chord.
2. **Mnemonic letter.** The key is the initial of the thing acted on or launched — T terminal,
   B browser, E explorer.
3. **One letter, one meaning — per namespace.** Within one namespace — a layer, or a declared
   sub-namespace like the WM's app tier — a letter keeps one mnemonic. Separate namespaces never
   collide: telegram's T (app tier) and terminal's T (main tier) coexist.
4. **Shift is the first variant, everywhere.** The Shifted chord is the stronger/move/reverse
   form of the unshifted one, never an unrelated action: `Ctrl+Z` → `Ctrl+Shift+Z` in apps,
   `SUPER + n` → `SUPER + SHIFT + n` in the WM. Where a layer defines a second-variant modifier,
   a key claims it only when its Shift slot is already taken.
5. **Direction is vim.** `H`/`J`/`K`/`L` read left/down/up/right — natively in TUIs, lifted into
   the WM, and in any app whose directional binds are configurable. The four letters are reserved
   for direction in every namespace they appear in; arrows may duplicate a vim chord, never
   replace it.
6. **macOS as tiebreaker.** Super sits where Cmd sits on a Mac keyboard. When two chords serve
   equally well, prefer the one that doesn't fight entrenched Cmd muscle memory — but never trade
   a strong mnemonic for it.
7. **Describable.** A custom bind carries a description wherever the tool supports one; an
   undescribed bind is invisible to any future cheatsheet.

# The WM layer: Super tiers

| Tier | Chord | Meaning |
|---|---|---|
| main | `SUPER + key` | The desktop's home row: window/workspace focus, session control, everyday launches |
| variant | `SUPER + SHIFT + key` | The stronger/move/reverse form of the same key's main action — never unrelated |
| alternative | `SUPER + ALT + key` | The second variant of the same key's main action, claimed only when Shift is taken |
| app | `SUPER + CTRL + key` | Summon/dismiss the background app whose initial is `key` (special-workspace toggles) |

The alternative tier is macOS's Cmd+Option semantic on Linux keys: the direction keys carry a
directional verb per tier — focus (main), move (Shift), resize (Alt) — and resize is the tier's
founding tenant. No two-modifier headroom remains; a family that ever outgrows the tiers gets a
submap entered from a main-tier chord. The long tail of rare actions goes through the launcher
(rule 1), so four tiers cover everything a chord should hold.

Dedicated keys behave, not just exist: an action on a hardware key works on the lock screen
(audio, brightness) and repeats while held when it is analog.

# The app layers

* **GUI apps** keep their platform defaults — the CUA/HIG chords arrive from the toolkit and are
  left alone. A custom GUI bind goes on `Ctrl` (+ `Shift` for its variant), never on Super.
* **The terminal emulator's** chrome stays inside `Ctrl + Shift`; what it doesn't use there is
  its headroom, not app space.
* **TUI custom binds** follow vim motions and the tool's own upstream idiom — aerc's mirrored
  defaults are the live example — with bare Alt available per the conditional-Alt rule above.

# Related

* [/reference/shortcut-standards.md](/reference/shortcut-standards.md) — what each platform
  standard assigns; the consensus the layer table composes.
* [hyprland-lua-config](hyprland-lua-config.md) — how this repo's Hyprland realizes the WM layer:
  bind form, `binds.mods`, flags, descriptions.
* [uwsm-session](uwsm-session.md) — how a Hyprland bind launches apps without landing them in the
  compositor's unit.
