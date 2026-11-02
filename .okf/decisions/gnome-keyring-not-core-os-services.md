---
type: Decision
title: The hyprland mixin names its system services instead of taking gnome.core-os-services
description: Only the GNOME keyring is wanted from the aggregate; hyprland's own module already supplies the shared desktop plumbing, and the aggregate puts gnome-session ahead of hyprland in xdg.portal.configPackages.
tags: [decision, hyprland, gnome, keyring, portals, secret-service]
generated:
  by: claude-code/claude-opus-5
  at: 2026-11-02T00:00:00Z
---

# The rule

`modules/nixos/mixins/desktop-environment/hyprland/default.nix` enables three system services by
name — `gnome.gnome-keyring`, `libinput`, `udisks2` — and not
`services.gnome.core-os-services`.

`services.gnome.gcr-ssh-agent.enable = false` is part of the keyring line, not an afterthought:
its upstream default is `config.services.gnome.gnome-keyring.enable`, so enabling the keyring
otherwise starts a second SSH agent competing with the 1Password one
(`modules/home/public/1password.nix`).

Two of the aggregate's other services reach [wintermute](/hosts/wintermute.md) alone:
`hardware.bluetooth` as a raw host line, and `services.upower` behind `mixins.hardware.battery`.
That mixin runs TLP, not power-profiles-daemon — the two cannot coexist.

# Why

The aggregate's useful half is already present. `programs.hyprland` pulls in
`wayland-session.nix` and `services.graphical-desktop`, which between them give `polkit`,
`dconf`, `xdg-desktop-portal-gtk`, `xdg.mime`/`icons`/`autostart`/`menus`,
`fonts.enableDefaultPackages` and `hardware.graphics`; `networkmanager`, `rtkit` and
`accounts-daemon` come from this repo's own mixins. What remained unique was one wanted service
and a dozen unwanted ones — a file indexer, media sharing, Evolution's data server, online
accounts.

It was also actively harmful at the portal layer: it added `xdg-desktop-portal-gnome` and placed
`gnome-session` *before* hyprland in `xdg.portal.configPackages`, so GNOME won backend selection
in the hyprland session.

The mixin is `services.udisks2.enable`'s sole owner.

The keyring itself is kept rather than replaced because it is the Secret Service
(`org.freedesktop.secrets`) provider the tree's Electron apps, vscodium and the
Nextcloud/OpenCloud clients expect. Its NixOS module is self-contained — it wires
`security.pam.services.login.enableGnomeKeyring` itself, and greetd defaults its own PAM entry off
`services.gnome.gnome-keyring.enable`, so login auto-unlock needs no explicit wiring.

`libinput` looks incidental and is not: `services.libinput.enable` gates libinput's udev quirks
database as well as the X11 input driver, and only the latter is conditional on
`services.xserver.enable` — which is false here.

`upower` sits in `mixins.hardware.battery` rather than this mixin, because it is a property of the
machine rather than of the session — and the [yas](/apps/yas.md) mixin derives
`programs.yas.config.battery` from `osConfig.mixins.hardware.battery.enable` so the fact is stated
once.

That coupling is the reason the capability exists rather than two host lines. yas' battery module
is `AstalBattery`, a UPower D-Bus client, and the client is constructed on *every* host regardless
of whether the module renders: `Bar/index.tsx` imports it statically and `services/battery.ts`
calls `AstalBattery.get_default()` at module scope, so `lazyAccessor` defers the bindings, not the
client. Without the daemon that path logs a `critical` and yields null
(`lib/battery/src/device.vala`), harmless only while `showBattery` is false.

# Related

* [architecture/uwsm-session](/architecture/uwsm-session.md) — the rest of what `programs.hyprland` brings.
* [hosts/wintermute](/hosts/wintermute.md) — the only host taking bluetooth or upower.
* [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) — why host deltas are raw options, not mixin knobs.
