---
type: Architecture Pattern
title: Host profiles
description: A profile is a reusable host role — a named set of mixin enables that a class of machines shares, selected per host by the `profile` string in the flake record.
tags: [architecture, profiles, hosts, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-04T00:00:00Z
verified:
  - by: claude-code/claude-fable-5
    at: 2026-09-04T00:00:00Z
---

# What a profile is

A profile is a **role**: a named bundle of mixin `enable`s that a *class* of machines shares. It lives as a plain NixOS module under `modules/nixos/profiles/*.nix` and does two things, no more:

* flips `mixins.<category>.<name>.enable` for the capabilities that define the role;
* occasionally sets a non-mixin default universal to the role (e.g. `console.useXkbConfig = true` in `desktop` — a tty↔xkb concern every graphical host wants).

A profile never sets arbitrary upstream options or per-machine values. **Profiles compose *selections*; [mixins](mixin-pattern.md) *configure*; hosts *deviate*.** Keeping those three layers apart is the whole point.

# Selection: the flake is the registry

Each host record in `flake.nix#nixosConfigurations` carries a `profile` string. `mkNixosConfiguration` resolves it to `nixosModules."profiles-<profile>"` and adds it to the module list next to the host module — same site, same `context` as `hostname` (see [entry-points](entry-points.md)). So the flake host list answers "what machine is this and what role does it play" at a glance; you never open a host file to learn its role.

`profile` is optional (`profile ? null`); a host with no role omits it.

```nix
{ hostname = "HAL9000"; profile = "hyprland-desktop"; usernames = [ "joker9944" ]; … }
```

# One profile per host

A host selects **exactly one** profile — a string, not a list. Roles a machine plays *in addition* (a k8s node that is also a NAS) are **not** a second profile; those capabilities are mixins the host enables directly. Rationale and the rejected alternatives (a profile list; builder-injected `base`) live in [decisions/host-profiles](/decisions/host-profiles.md).

Layering happens *inside* the profile tree via `imports` of the flake keys (`imports = [ flake.nixosModules.profiles-desktop ]`), and only for genuine **specialization** (IS-A): `hyprland-desktop` imports `desktop` imports `base` — each *is a* refinement of the one before. A linear chain, not a grab-bag.

# Profiles are high-level — never per-machine

**A profile must serve a class of machines, never exactly one.** The moment a profile would be selected by a single host it is not a role — it is that host's config in a profile costume, and it belongs in `modules/nixos/hosts/<host>/mixins.nix` (enable deltas) or `modules/nixos/hosts/<host>/default.nix` (arbitrary quirks) instead.

This is the guard against the failure mode where every machine grows a bespoke `foo-host` profile and the profile layer becomes a second, worse copy of the host layer. The test is concrete: *would a second, hypothetical machine select this profile unchanged?* If no, it is a host delta. Prefer a few broad roles refined by a short `imports` chain over many narrow ones.

# The layers, by example

| Layer | Answers | Lives in | Example |
|---|---|---|---|
| Profile | "what role does this *class* of machine play?" | `modules/nixos/profiles/*.nix` | `desktop` enables `fonts`, `pipewire`, `networkmanager`, the limine loader, … |
| Mixin | "what single capability?" | `modules/nixos/mixins/**` | `programs.steam`, `hardware.nvidia` |
| Host delta | "what is unique to *this* machine?" | `modules/nixos/hosts/<host>/{mixins,default}.nix` | HAL9000's `nvidia`+`steam`+`docker`; wintermute's `openssh`; per-host limine branding colour |

# Current profiles

`base` ← `desktop` ← `hyprland-desktop` (each `imports` the one on its left):

* **base** — every machine: `nix`, `localization`, `git`/`vim`/`utilities`, `maintenance`, `tailscale`.
* **desktop** — graphical baseline: the limine loader, `fonts`, `networkmanager`, `theme.orchidlift-lume`, `pipewire`, `printing`, `_1password`, `gnupg`, `home-manager`, plus `console.useXkbConfig`.
* **hyprland-desktop** — picks the DE + DM: `desktopEnvironment.hyprland`, `displayManager.regreet`.

Both current hosts select `hyprland-desktop`; their `mixins.nix` files hold only deltas.

# Related

* [mixin-pattern](mixin-pattern.md) — the enable flags a profile selects.
* [entry-points](entry-points.md) — where `mkNixosConfiguration` resolves the `profile` string.
* [decisions/host-profiles](/decisions/host-profiles.md) — why one profile per host, and why multi-role is a mixin concern.
