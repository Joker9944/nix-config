---
type: Architecture Pattern
title: Shortcut scheme
description: Modifier ownership per layer — Super to the WM, Ctrl to apps, Ctrl+Shift to the terminal emulator, bare keys to TUIs — and the composition rules a new bind must pass.
tags: [architecture, keybindings, hyprland, convention]
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
| WM / global (Hyprland) | every chord containing `SUPER`, plus dedicated keys (`XF86*`, `PRINT`) |
| GUI apps | `Ctrl` (+ `Shift` variants) — their platform defaults, left alone |
| Terminal emulator | `Ctrl + Shift` |
| TUIs | bare letters, vim motions, Alt-as-Meta (`ESC`-prefixed), and the `Ctrl` control codes upstream defines |
| Dedicated keys | bare `XF86*` / `PRINT`; a modifier narrows the target, never changes the action |

Three consequences the table implies but that deserve stating:

* The WM never grabs a Super-less chord. Ctrl-anything belongs to whatever has focus, including
  Windows-idiom system chords like Ctrl+Alt+Del.
* Bare `Alt` chords stay unbound everywhere — at the app layer Alt carries menu access keys,
  inside the terminal it is Meta (readline word motions, Emacs `M-`), and a WM grab would shadow
  both.
* Prefer the WM's window management over any app's built-in tabs, splits, or layouts, so managing
  windows reads the same regardless of the app.

# Super tiers

Concrete modifier strings live in one place — `binds.mods` in
`modules/home/mixins/desktop-environment/hyprland/input/default.nix`; every bind interpolates
them, none hard-codes. The tiers mean:

| Tier | Chord | Meaning |
|---|---|---|
| main | `SUPER + key` | The desktop's home row: window/workspace focus, session control, everyday launches |
| variant | `SUPER + SHIFT + key` | The stronger/move/reverse form of the same key's main action — never unrelated |
| app | `SUPER + CTRL + key` | Summon/dismiss a background app (special-workspace toggles) |

`SUPER + ALT` is deliberately unassigned headroom, not a tier — Alt thereby appears nowhere in the
scheme. The long tail of rare actions goes through the launcher (see the first composition rule),
so three tiers cover everything a chord should hold.

The variant row is the standards' Shift rule, not a free tier: `SUPER + n` focuses workspace *n*,
so `SUPER + SHIFT + n` moves the window there, and any future focus/move pair composes the same
way. (The option's attr for this tier is named `workspace`, after that dominant use.)

# Composition rules

A new bind passes all of these:

1. **Earn the chord.** A bind exists only for actions used reflexively, many times a day.
   Anything you'd have to *remember* is the launcher's job — clipboard history, calculator,
   emoji, power menu. A bind you keep forgetting isn't under-advertised, it's mis-assigned:
   delete it, don't demote it to a rarer chord.
2. **Mnemonic letter.** The key is the initial of the thing acted on or launched — T terminal,
   B browser, E explorer.
3. **Direction is vim.** A directional action reads `H`/`J`/`K`/`L` as left/down/up/right — the
   TUI layer's motion vocabulary lifted to the WM. With Shift it composes as the variant rule:
   focus left on `SUPER + H`, move left on `SUPER + SHIFT + H`. One-letter-one-meaning then
   reserves the four letters for direction across all Super tiers; arrows may duplicate a vim
   chord, never replace it.
4. **One letter, one meaning.** A letter keeps its mnemonic across every Super tier; tiers change
   scope, not meaning. A letter meaning "terminal" on main cannot mean "telegram" on app.
5. **Shift is the variant.** `SUPER + SHIFT + key` exists only as the stronger form of
   `SUPER + key`, never as an unrelated slot.
6. **Dedicated-key behavior.** An action on a dedicated key works on the lock screen (audio,
   brightness) and repeats while held when analog — Hyprland spells these `locked = true` and
   `repeating = true`.
7. **macOS as tiebreaker.** Super sits where Cmd sits on a Mac keyboard. When two chords serve
   equally well, prefer the one that doesn't fight entrenched Cmd muscle memory — but never trade
   a strong mnemonic for it.
8. **Describe it.** Every bind passes `description`; an undescribed bind is invisible to any
   future cheatsheet.
9. **Launch discipline (Hyprland-specific).** Under the UWSM session, anything long-running a
   bind starts goes through `cfg.mkAppCommand` / `cfg.mkAppEntryCommand` — see
   [uwsm-session](uwsm-session.md). The rule dies with the compositor: GNOME and KDE launch
   through their own machinery.

# Related

* [/reference/shortcut-standards.md](/reference/shortcut-standards.md) — what each platform
  standard assigns; the consensus the layer table composes.
* [uwsm-session](uwsm-session.md) — how a bind launches apps without landing them in the
  compositor's unit.
* [hyprland-lua-config](hyprland-lua-config.md) — the config surface binds are written in (`bind`
  at the top level of `settings`).
