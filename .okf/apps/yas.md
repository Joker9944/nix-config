---
type: Application
title: yas — yet another shell
description: The AGS v3 / GJS desktop shell in apps/yas — per-monitor bar and notification popups, built by its own flake and delivered as a home-manager module.
resource: https://github.com/Joker9944/nix-config/tree/main/apps/yas
tags: [app, yas, ags, gjs, typescript, hyprland, gtk4]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-16T00:00:00Z
---

# What it is

A GTK4 desktop shell written in TypeScript, run on GJS through [AGS](https://aylur.github.io/ags/) v3
(`ags` JS lib 3.1.x, JSX from `gnim`). It draws a bar and notification popups and is the statusbar
the hyprland tree selects — `users/mixins/desktop-environment/hyprland/statusbar/default.nix` enables
`yas` and disables `waybar` and `ashell`.

Every window is named `yas_<component>_<connector>` (`yas_bar_DP-2`, `yas_notifications_DP-2`), which
is also the layer namespace hyprland sees — so one `layerrule` matching the `yas_` prefix covers the
whole shell. The waybar mixin's `blur on, xray on` rule is the precedent; yas has none.

# Runtime shape

`src/app.tsx` is the only entry point: `app.start` maps over `app.monitors` and mounts a `Bar` and a
`Notifications` window per monitor. Unmounting does *not* dispose the widget — gnim's `This` only
disconnects the handlers it added — so every window carries
`$={(self) => onCleanup(() => self.destroy())}` or it survives the monitor being unplugged.
The bar is a `centerbox` — workspaces at the start, clock in the centre, and the stat modules
(CPU, GPU, memory, disk, network, battery, audio) at the end. GPU and battery are the only ones behind
a config flag.

# Three layers

| Layer | Holds | Rule |
|---|---|---|
| `src/services/` | One file per data source; exports `Accessor`s and the imperative actions on them (`focusWorkspace`, mute/volume setters). | No JSX, no formatting. |
| `src/components/` | JSX only. Bar modules wrap `Module` / `LabelStatModule` / `IconStatModule` from `modules/Module.tsx` so every stat gets the same box, classes and spacing. | Derived values are module-level `const`s, not recomputed per render. |
| `src/helpers/` | Accessor plumbing, memoisation, formatters, `SPACING`, smoothing. Re-exported from `helpers/index.ts`. | Pure; no GObject singletons. |

The API in use is AGS v3: `Accessor`, `createBinding`, `createState`, `createComputed`, `createPoll`,
`For`, `This`, `onCleanup`, lowercase intrinsic elements (`<box>`, `<label>`, `<menubutton>`), and
typed GIR namespaces via `gi://…`. The v1/v2 vocabulary — `Widget.Box`, `Variable`, `bind()`,
`App.config` — does not exist here; reaching for it is the standard hallucination in this codebase.

`@girs` also mistypes every function that takes a `GError**`: GJS raises on failure, but the
declaration keeps the C success flag, so `const [ok] = Pango.parse_markup(…)` type-checks and its
`ok === false` branch is unreachable. Such calls need `try`/`catch`, not a boolean check.

# Everything is lazy, on purpose

Every service accessor is wrapped in `lazyAccessor` (`helpers/accessors.ts`), which defers the real
`createPoll` / `createBinding` until something first peeks or subscribes. Module-level accessors would
otherwise start their timers at *import* time — and `Bar/index.tsx` imports `Gpu` and `Battery`
unconditionally even when `showGpu` / `showBattery` are false. Laziness is what keeps a desktop
without a battery from polling UPower, and a desktop without an Nvidia card from spawning
`nvidia-smi` every second. Keep new services in that shape.

# Never destructure a live property

`const { primary } = AstalNetwork.get_default()` copies the value once and never sees
`notify::primary` again — the same for `Wp.defaultSpeaker`, which swaps to a *different* `Endpoint`
whenever the default output changes. Hold the singleton, not its properties. For display, chain the
binding — `createBinding(wp, "defaultSpeaker", "volume")` re-subscribes when the intermediate object
changes; for actions, read through the singleton at call time (`wp.get_default_speaker().set_mute(…)`)
and export that as a function, so components never hold a GObject reference of their own.

Parameterised services use `memoize` (`Disk`'s per-path accessor) and `weakMemoize` when the key is a
GObject (`Audio`'s per-endpoint CSS accessor), so repeated calls return the *same* accessor rather
than a second subscription.

# Styling

`src/styles/main.scss` is imported as a string and handed to `app.start({ css })`; the ags bundler
compiles the SCSS (it wraps dart-sass) at build time. What that stylesheet carries is layout only —
padding, font sizes, border radii. Colours come from the GTK4 stylesheet the theme pipeline generates
(see `apps/nix-schemes`), which is why components lean on stock GTK/libadwaita classes: `background`,
`frame`, `heading`, `monospace`, `numeric`, `circular`, `suggested-action`.

Selectors bind through two different props. `cssName` sets the CSS *node name* — that's what makes
`window > bar { workspaces … }` work — while `cssClasses` (or the `class` shorthand) adds classes.
Several classes in the JSX (`base-background`, `inactive`, `spacer`, the `low`/`normal`/`critical`
urgency classes) have no rule in either stylesheet yet.

# Notifications

`services/notifications.ts` wraps `AstalNotifd` twice: `timeoutNotificationsAccessor` holds an
auto-expiring list (per-notification `expireTimeout`, falling back to 10 s) and is what the popup
window renders; the un-timed `staticNotificationsAccessor` and `Notification`'s `showHeader` /
`showActions` blocks are built but nothing mounts them. The popup window hides itself when the list
empties or do-not-disturb is on.

yas *is* the notification daemon — the first `AstalNotifd` instance in the session takes
`org.freedesktop.Notifications` and serves `io.astal.notifd` alongside it. The `astal-notifd` binary
is the CLI client of that second name, so it drives the running yas: `-l` dumps the store as JSON,
`-t` toggles do-not-disturb, `-i` / `-c` invoke and close. yas only ever *reads* `dontDisturb`, which
makes the CLI the sole way to flip it.

# Configuration

`services/config.ts` reads `$XDG_CONFIG_HOME/yas/config.json` **once at startup** and exports plain
booleans (`showGpu`, `showBattery`) — not accessors. A config change therefore needs a restart, never
a re-render, and a new key is three edits: the `Config` type, the export, and the consumer.

The file is written by the home-manager module from `programs.yas.config` (a free-form JSON attrset),
so the schema lives in TypeScript, not in the module's options. Which host sets what is recorded with
the hosts — [HAL9000](/hosts/HAL9000.md) and [wintermute](/hosts/wintermute.md).

# How it reaches the desktop

`apps/yas` is its own flake, consumed by the root as the `yas` input with `inputs.nixpkgs.follows`.
Three outputs matter:

* `packages.<system>.yas` — a `stdenv.mkDerivation` that copies the source to `$out/share` and runs
  `ags bundle src/app.tsx` into a single executable. `extraPackages` (the astal libraries plus
  `libadwaita`, `libsoup_3`, `libgtop`) is shared between the bundler's ags and the derivation, so a
  new GIR dependency has to be added there or the bundle fails to find the typelib at runtime.
  `packages.<system>.astal-notifd` re-exports the ags input's `notifd` so the module can install its
  CLI; it is the same store path `extraPackages` already pulls in, so it adds nothing to the closure.
* `homeModules.yas` — `programs.yas` with `enable`, `package`, `notifd.package`, `config`, and
  `systemd.{enable,target}`. It installs both packages, writes `xdg.configFile."yas/config.json"`, and
  defines a user unit bound to `wayland.systemd.target` and `tray.target`.
* `overlays.yas` — exists but is not applied by this repo; the module's `package` default reaches
  into the flake directly.

The mixin at `users/mixins/desktop-environment/hyprland/statusbar/yas/` is thin on purpose: it imports
the home module and ties `systemd.enable` to `programs.yas.enable`.

The unit lists `gtk-4.0/gtk.css` and `yas/config.json` under `X-Reload-Triggers`, and home-manager's
`systemd.user.startServices` defaults to `sd-switch`, so a theme or config change restarts yas on
`nh home switch` — a package change restarts it anyway.

# Related

* [workflows/develop-yas](/workflows/develop-yas.md) — the edit-run-check loop and the toolchain traps.
* [architecture/mixin-pattern](/architecture/mixin-pattern.md) — how the statusbar mixin selects it.
* [architecture/uwsm-session](/architecture/uwsm-session.md) — the session target the unit hangs off.
* [decisions/util-lib-split](/decisions/util-lib-split.md) — the sub-flake locking rules yas shares
  with the other `apps/` flakes.
