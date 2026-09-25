---
type: Reference
title: Shortcut modifier standards
description: What each platform standard assigns to which modifier — CUA's Ctrl floor, GNOME/KDE reserving Super for the system, macOS Cmd semantics, i3's mod/mod+Shift pair, and why terminals live on Ctrl+Shift.
tags: [reference, keybindings, shortcuts, hig]
generated:
  by: claude-code/claude-fable-5
  at: 2026-09-25T00:00:00Z
sources:
  - id: cua
    resource: https://en.wikipedia.org/wiki/IBM_Common_User_Access
    title: IBM Common User Access (1987)
  - id: gnome-hig
    resource: https://developer.gnome.org/hig/guidelines/keyboard.html
    title: GNOME HIG — keyboard guidelines
  - id: kde-kbd
    resource: https://docs.kde.org/trunk_kf6/en/khelpcenter/fundamentals/kbd.html
    title: KDE fundamentals — common keyboard shortcuts
  - id: macos-hig
    resource: https://developer.apple.com/design/human-interface-guidelines/keyboards
    title: Apple HIG — keyboards
  - id: i3-guide
    resource: https://i3wm.org/docs/userguide.html
    title: i3 user guide
  - id: kitty-overview
    resource: https://sw.kovidgoyal.net/kitty/overview/
    title: kitty — default shortcuts
  - id: control-chars
    resource: https://jvns.ca/blog/2024/10/31/ascii-control-characters/
    title: ASCII control characters in my terminal (Julia Evans)
  - id: readline
    resource: https://tiswww.case.edu/php/chet/readline/rluserman.html
    title: GNU Readline user manual
---

# The consensus is two modifier layers

Every standard below lands on the same split: the key in the Super position belongs to the
system/window layer, and Ctrl (Cmd on macOS) belongs to the focused app. Two rules recur on top,
everywhere:

* **Shift never means a new action.** It reverses, extends, or strengthens the unshifted chord:
  Ctrl+Z → Ctrl+Shift+Z redo,[^gnome-hig] Alt+Tab → Alt+Shift+Tab backwards,[^kde-kbd] $mod
  focuses → $mod+Shift moves.[^i3-guide]
* **Letters are mnemonic.** Pick the initial of the thing acted on, so the chord teaches
  itself.[^gnome-hig]

# CUA is the floor

IBM's 1987 Common User Access fixed the conventions every GUI since assumes — F1 = help, Alt +
letter opens the underlined menu, and the edit family that settled as Ctrl+X/C/V/Z.[^cua] Apps
inherit these from their toolkit; nothing else may shadow them.

# Linux desktops reserve Super for the system

GNOME: "GNOME reserves the use of the Super key for use in system shortcuts. Super should
therefore not be used by apps." Apps get Ctrl + letter, Shift+Ctrl reverses or extends, and Alt is
off-limits for app shortcuts because it carries access keys.[^gnome-hig] KDE has the same shape:
Meta drives the Plasma/workspace layer (Meta+Tab, Meta + arrows), Ctrl the apps, Shift the
reverse.[^kde-kbd]

# macOS is the same structure, shifted one key

Cmd — physically the Super position — is the primary app modifier, Shift the preferred secondary,
Cmd+Option the rarer variants; Ctrl stays nearly unclaimed, which is why terminal control codes
coexist peacefully there.[^macos-hig] Consequence for a Linux scheme: a Super chord lands on the
same finger position as a Cmd chord, so every Super + letter has Cmd + letter muscle memory to
either exploit or fight.

# Tiling WMs: $mod acts, $mod+Shift moves

i3 codifies the community convention: one $mod for everything the WM does — Mod4/Super recommended
because it "largely prevents conflicts with application-defined shortcuts" — with $mod + key
acting on the focused container and $mod + Shift + key moving it, including to
workspaces.[^i3-guide]

# Terminals: Ctrl is spoken for

The TTY line discipline turns Ctrl + letter into control codes before an app sees a key event —
Ctrl+C is SIGINT, Ctrl+D EOF, Ctrl+Z suspend.[^control-chars] Terminal emulators therefore put
their own chrome one modifier up on Ctrl+Shift — copy, paste, tabs, windows; kitty's defaults are
Ctrl+Shift throughout[^kitty-overview] — and TUIs inside the terminal live on bare letters and vim
motions instead of chords.

Alt is the exception that survives: encoded as an `ESC` prefix, it reaches TUIs intact as the
**Meta** key — readline's M-f/M-b word motions and M-d kill-word are Alt chords[^readline] — making
it the TUI world's one free, visible modifier. Menu-bar terminals resolve the clash with GUI
access keys by suppressing their own Alt mnemonics, surrendering the key to Meta.

# Related

* [/architecture/shortcut-scheme.md](/architecture/shortcut-scheme.md) — the scheme this repo
  composes from these standards.

[^cua]: IBM Common User Access (1987)
[^gnome-hig]: GNOME HIG — keyboard guidelines
[^kde-kbd]: KDE fundamentals — common keyboard shortcuts
[^macos-hig]: Apple HIG — keyboards
[^i3-guide]: i3 user guide
[^kitty-overview]: kitty — default shortcuts
[^control-chars]: ASCII control characters in my terminal (Julia Evans)
[^readline]: GNU Readline user manual
