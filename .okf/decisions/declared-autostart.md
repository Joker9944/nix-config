---
type: Decision
title: Autostart entries are declared, never self-registered
description: '`xdg.autostart.readOnly = true` makes `~/.config/autostart` a read-only store symlink, because an app that writes its own entry records `/proc/self/exe` and so bypasses its Nix wrapper.'
tags: [decision, xdg, autostart, desktop-entry, wrapper]
generated:
  by: claude-code/claude-opus-5
  at: 2026-10-04T00:00:00Z
---

# The rule

`modules/home/mixins/xdg.nix` sets `xdg.autostart.readOnly = true`, so `~/.config/autostart` is a
symlink to a store directory. A user-level autostart entry exists only if some mixin puts it in
`xdg.autostart.entries`; an app's own "launch at login" toggle cannot write, and fails quietly if
used. System entries in `/etc/xdg/autostart` are a separate path and unaffected.

# Why self-registration breaks

An app writes its entry's `Exec=` from `applicationFilePath()`, which on Linux reads
`/proc/self/exe`. Under `makeBinaryWrapper --inherit-argv0` that is the *inner*
`bin/.<name>-wrapped` binary, not the `bin/<name>` wrapper — so the entry launches the app with none
of the wrapper's `QT_PLUGIN_PATH` / `NIXPKGS_QT6_QML_IMPORT_PATH` / `XDG_DATA_DIRS`. A Qt app whose
own QML modules live in its output then `qFatal`s on the first QML load. It also pins an absolute
store path that a GC dangles.

opencloud-desktop is the case that bit: it cored on every login until
`modules/home/mixins/programs/opencloud-desktop.nix` declared the entry instead.

A packaged `share/applications/*.desktop` does not have this problem — its `Exec=` is a bare command
name, resolved on `PATH` to the wrapper. That makes it the right thing to base an autostart entry on.

# Shape of an entry

`runCommandLocal` installs the packaged entry and `substituteInPlace --replace-fail` rewrites the
`Exec` line — adding a background/silent switch, or dropping one that would open a window at login.
`--replace-fail` is the point: upstream changing the line breaks the build instead of changing
behaviour silently. Precedents: `modules/home/public/1password.nix`,
`modules/home/mixins/programs/opencloud-desktop.nix`.

Two naming constraints:

* **The basename is the installed path.** Home-manager links each entry by basename, so the
  derivation must install the file under the name you want in `~/.config/autostart`.
* **Match the name the app checks**, which need not be the packaged one — opencloud ships
  `opencloud.desktop` but looks for `OpenCloud.desktop`. Get it right and the app's own checkbox
  reads as already enabled, so nobody is tempted to toggle it.

This is not [no-ifd](no-ifd.md) territory: a derivation path is interpolated, never read at eval
time, and home-manager's own `xdg.autostart` is a `runCommandLocal` over the entry list regardless.

# Related

* [desktop-files-at-build-time](desktop-files-at-build-time.md) — the same line between interpolating
  a desktop file's path and reading its contents.
* [/architecture/uwsm-session](/architecture/uwsm-session.md) — autostart entries get their own
  systemd unit and slice for free; this is the other half of what makes them work.
