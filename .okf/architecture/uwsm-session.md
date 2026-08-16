---
type: Architecture Pattern
title: UWSM session and app slices
description: Hyprland runs under UWSM, so anything long-running a bind or rofi launches must go through `cfg.mkAppCommand` or `cfg.mkAppEntryCommand`, or it lands inside the compositor's own systemd unit.
tags: [architecture, hyprland, uwsm, systemd, rofi]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-14T12:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# The compositor is a systemd unit

`programs.hyprland.withUWSM = true` (`hosts/mixins/desktop-environment/hyprland/default.nix`) puts
the compositor in `wayland-wm@hyprland.desktop.service` under `session.slice`, and gives
applications `app-graphical.slice`.

A process spawned from `hl.dsp.exec_cmd(…)` inherits the compositor's cgroup, so it becomes part of
the compositor's unit rather than getting its own. `uwsm app` is what moves it: it registers a
transient scope in `app-graphical.slice` before exec'ing.

XDG autostart entries land correctly on their own, as does anything the tree declares as a
home-manager systemd user service. Binds and rofi are the two paths that need help.

# `mkAppCommand` and `mkAppEntryCommand`

Both live in `users/mixins/desktop-environment/hyprland/hyprland/default.nix`, alongside the other
`withUWSM`-conditional wiring, and both are gated on `osConfig.programs.hyprland.withUWSM` — with
UWSM off they degrade to something that still works.

* `mkAppCommand` takes command elements and prefixes `uwsm-app --`. Ungated it is plain
  `custom.libUtil.strings.mkCommand`, so the command runs unwrapped.
* `mkAppEntryCommand` takes `custom.lib.requireDesktopFile`'s argument set and yields the entry ID
  wrapped by `mkAppCommand`. Ungated it yields `lib.getExe package`. It cannot share the other's
  fallback: an entry ID is executable *only* because uwsm resolves it, so degrading to a bare
  `mkCommand` would emit `hl.dsp.exec_cmd("librewolf.desktop")` and break the bind.

Wrapping happens wherever the command is built, including inside `cfg.terminal.mkRunCommand`, so
every terminal-app bind (`btop`, `yazi`, `numbat`) inherits it without repeating itself. Those share
`kitty` as argv[0], which uwsm would otherwise use for the unit name — hence `mkAppCommand`'s `name`
argument, which passes `uwsm app -a` so each gets its own scope name.

It wraps long-running apps only. Multimedia and brightness keys, `loginctl lock-session`,
`hyprshutdown`, `grimblast` and the `cliphist` picker stay bare: they exit in milliseconds, several
are `repeating = true`, and a scope per keypress is pure latency.

`uwsm-app` rather than `uwsm app` — it is a drop-in client for `wayland-wm-app-daemon.service`
(which it starts on demand) and skips the Python interpreter startup that would otherwise be paid on
every keypress.

# Desktop Entry ID, where it fits

Given an entry ID, `uwsm app` adds `SourcePath=`, a unit description from `Name`/`GenericName`,
`Path=` as working directory, and the packaged `Exec` line. Reach for it through
`cfg.mkAppEntryCommand`, which routes through `custom.lib.requireDesktopFile` so a renamed entry
fails the build instead of producing a bind that silently does nothing — see
[custom-lib](custom-lib.md).

Two constraints decide where it applies:

* **ID, never a store path.** `uwsm app` accepts both, but a path pins the bind to a generation that
  can be garbage-collected.
* **Not for `Terminal=true` entries.** `btop.desktop` and `yazi.desktop` are such entries; uwsm would
  route them through the xdg-terminal-exec-selected terminal with no `--app-id`, and the
  `cfg.terminal.mkWindowRules` `class:` rules would stop matching. Those binds keep the executable
  form built by `cfg.terminal.mkRunCommand`.

`xdg-open` is **not** the way to launch an entry outside uwsm, though it looks like it. Its
`open_generic()` treats the argument as a *document*: it resolves the MIME type
(`application/x-desktop`) and hands off to whatever handler is registered, typically a text editor.
It also wants a path rather than an ID, and does not fork, so it would linger as a parent process.
`gtk-launch` (in `gtk+3`'s `bin`) and `dex` are the real tools, but neither is on `PATH` here —
hence `lib.getExe`.

# rofi

`programs.rofi.extraConfig` carries two hooks, both set from `cfg.mkAppCommand`:

* `run-command` — `drun` selections. Verified in rofi 2.0.0 source: `exec_cmd_entry` →
  `helper_execute_command` → `config.run_command`, with `{cmd}` substituted and then shell-parsed
  into argv.
* `run-shell-command` — `Terminal=true` entries, default `{terminal} -e {cmd}`.

`DBusActivatable=true` entries bypass both, which is fine: dbus activation already yields a unit.

rofi passes only the *expanded Exec line*, never the entry ID, so rofi-launched apps get correct
slicing but plainer unit names. `uwsm app` would read `DESKTOP_ENTRY_ID` / `_PATH` / `_NAME` from the
environment, but rofi 2.0.0 does not export them.

**Recheck after any rofi bump past 2.0.0.** Upstream's `next` branch both adds a GIO launch path
(`g_app_info_launch`) that *bypasses* `run-command` entirely, and starts exporting the
`DESKTOP_ENTRY_*` variables. The first would silently undo this; the second would make entry IDs
available for free.

`cfg.launcher.mkDmenuCommand` is deliberately untouched — the dmenu form is a stdin/stdout filter,
not an app launcher.

`nix build` proves the string was generated, nothing more; the check that means anything is
`cut -d: -f3 < /proc/<pid>/cgroup` on a running app.

# Related

* [hyprland-lua-config](hyprland-lua-config.md) — the config surface these binds are written in.
* [custom-lib](custom-lib.md) — `mkCommand`, `lookupDesktopFiles`, `requireDesktopFile`.
