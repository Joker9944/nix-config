---
type: Decision
title: Autostart entries are declared, never self-registered
description: '`xdg.autostart.readOnly = true` makes `~/.config/autostart` a read-only store symlink, because an app that writes its own entry records `/proc/self/exe` and so bypasses its Nix wrapper; a systemd user service is preferred over an entry, and `xdg.desktopEntries` is the `hiPrio` lever for displacing an entry a package ships.'
tags: [decision, xdg, autostart, desktop-entry, launcher, wrapper]
generated:
  by: claude-code/claude-opus-5
  at: 2026-10-04T00:00:00Z
---

# The rule

`modules/home/mixins/xdg.nix` sets `xdg.autostart.readOnly = true`, so `~/.config/autostart` is a
symlink to a store directory. A user-level autostart entry exists only if some mixin puts it in
`xdg.autostart.entries`; an app's own "launch at login" toggle cannot write, and fails quietly if
used. System entries in `/etc/xdg/autostart` are a separate path and unaffected.

An XDG entry is the fallback, not the first choice. Where the app tolerates it, a **systemd user
service** is preferred, for the graceful `ExecStop` and `Restart=on-failure` that the generated
autostart unit cannot express — `services.nextcloud-client` upstream,
`modules/home/public/opencloud-desktop.nix` here. The trade is uwsm's autostart drop-in, so such a
service lands in `app.slice` with a smaller environment; see
[/architecture/uwsm-session](/architecture/uwsm-session.md).

# Why self-registration breaks

An app writes its entry's `Exec=` from `applicationFilePath()`, which on Linux reads
`/proc/self/exe`. Under `makeBinaryWrapper --inherit-argv0` that is the *inner*
`bin/.<name>-wrapped` binary, not the `bin/<name>` wrapper — so the entry launches the app with none
of the wrapper's `QT_PLUGIN_PATH` / `NIXPKGS_QT6_QML_IMPORT_PATH` / `XDG_DATA_DIRS`. A Qt app whose
own QML modules live in its output then `qFatal`s on the first QML load. It also pins an absolute
store path that a GC dangles.

opencloud-desktop is the case that bit: it cored on every login until the mixin stopped letting it
self-register. It starts from a user service now, and `readOnly` is what keeps it from reinstating
its own entry alongside.

A packaged `share/applications/*.desktop` does not have this problem — its `Exec=` is a bare command
name, resolved on `PATH` to the wrapper. That makes it the right thing to base an autostart entry on.

# Shape of an entry

`runCommandLocal` installs the packaged entry and `substituteInPlace --replace-fail` rewrites the
`Exec` line — adding a background/silent switch, or dropping one that would open a window at login.
`--replace-fail` is the point: upstream changing the line breaks the build instead of changing
behaviour silently. Precedent: `modules/home/public/1password.nix`.

Two naming constraints:

* **The basename is the installed path.** Home-manager links each entry by basename, so the
  derivation must install the file under the name you want in `~/.config/autostart`.
* **Match the name the app checks** if it keeps one of its own, so its checkbox reads as already
  enabled — opencloud looks for `OpenCloud.desktop` though it ships `opencloud.desktop`.

This is not [no-ifd](no-ifd.md) territory: a derivation path is interpolated, never read at eval
time, and home-manager's own `xdg.autostart` is a `runCommandLocal` over the entry list regardless.

# One instance, one identity

A background instance only helps if a launcher-started one can hand off to it. opencloud's
single-instance IPC (kdsingleapplication) appends `XDG_SESSION_ID` to its socket name *only when the
variable is set*, so an instance started where it is absent never finds one started where it is
present: it becomes a second primary and then blocks indefinitely on the first's sync-database lock.
The mixin wraps the package with `--unset XDG_SESSION_ID` so every launch context shares one
namespace — also the honest scope for a daemon holding a single lock.
[/architecture/uwsm-session](/architecture/uwsm-session.md) covers why the contexts disagree.

The service takes its `package` from `programs.opencloud-desktop.package` for that reason: unit and
profile must resolve the same wrapper, or `ExecStop`'s `--quit` cannot reach the running instance.

# Displacing an entry a package ships

`xdg.desktopEntries` is the other lever, and it does not write to `$XDG_DATA_HOME` as the name
suggests — it adds a `lib.hiPrio` `makeDesktopItem` to `home.packages`, so the generated entry wins
the *profile* collision at `share/applications/<attr key>.desktop`. That makes it the way to suppress
an entry rather than shadow it, via `noDisplay = true`.

opencloud-desktop needs this too: upstream installs `opencloudcmd.desktop` byte-identical to
`opencloud.desktop` — same `Name`, same `Exec` — and launchers dedup by entry ID, not by name, so the
GUI is listed twice. Unfiled upstream, so there is no link for
[/workflows/track-upstream-blockers](/workflows/track-upstream-blockers.md) to watch.

# Related

* [desktop-files-at-build-time](desktop-files-at-build-time.md) — the same line between interpolating
  a desktop file's path and reading its contents.
* [/architecture/uwsm-session](/architecture/uwsm-session.md) — autostart entries get their own
  systemd unit and slice for free; this is the other half of what makes them work.
