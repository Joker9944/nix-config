---
type: Playbook
title: Add a new mixin
description: The 3-step process for adding either a home-manager or a NixOS mixin — drop the file, enable it, rebuild.
tags: [workflow, modules, home-manager, nixos]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-04T00:00:00Z
---

# Trigger

You want to add a reusable module (a new program, service, or subsystem toggle) that a host or user can enable with a flag.

# Steps

## 1. Pick the tree and category

| You're configuring | Tree | Category directories |
|---|---|---|
| Something in the user environment (programs, services, DE bits) | `modules/home/mixins/` | `programs/`, `services/`, `desktop-environment/`, `pwas/` |
| Something at the system level (boot, hardware, services, DE) | `modules/nixos/mixins/` | `boot/`, `desktop-environment/`, `display-manager/`, `hardware/`, `networking/`, `programs/`, `services/`, `virtualisation/` |

If uncertain, look at analogues in the existing tree.

## 2. Drop the file

Create `<tree>/<category>/<name>.nix` following the template in [architecture/mixin-pattern#shape](/architecture/mixin-pattern.md#shape), which also names the canonical minimal example.

If your mixin needs more than one nix file, or any non-nix files (patches, markdown, static config), expand it into a folder rather than a single `.nix` — see [architecture/module-layout](/architecture/module-layout.md).

Options assigned here are looked up per tree: `hm-options` for `modules/home/`, `nixos-options` for `modules/nixos/` — both on `PATH` from the dev shell; surface and hallucination traps in `.claude/skills/{home-manager-options,nixos-options}/SKILL.md`, build in [architecture/packages](/architecture/packages.md).

No manual registration is needed: the parent `default.nix` uses `mkDefaultModule` and picks up new files automatically (see [architecture/auto-discovery](/architecture/auto-discovery.md)).

## 3. Enable it

Home-manager: add to `modules/home/users/joker9944/config/mixins.nix`.
NixOS: add to `modules/nixos/hosts/<hostname>/mixins.nix`.

```nix
mixins.<category>.<name>.enable = true;
```

## 4. Rebuild

See [rebuild](rebuild.md).

# Anti-patterns

* Exposing multiple options beyond `enable`. See [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) — if the mixin needs a knob, put it in `modules/nixos/hosts/<host>/default.nix` or `modules/home/users/<user>/hosts/<host>/default.nix` as a plain override.
* Wrapping a *parametrized template* as a mixin. If the thing is really a function from per-host params to config (a disk layout, say), it belongs in `flake.lib`, not a mixin — see [architecture/custom-lib](/architecture/custom-lib.md) (`disko`).
* Hand-rolling a plugin's config generation when upstream ships a home-manager module — check first. Import via `imports = [ inputs.<flake>.homeManagerModules.default ]` inside `mkMixinModule` (imports stay structural; precedent: `modules/home/mixins/desktop-environment/kde-plasma.nix`). Especially worth it for plugins that "autobuild" config into their own directory, which fails on the read-only store.

# Related

* [architecture/mixin-pattern](/architecture/mixin-pattern.md) — the shape.
* [architecture/auto-discovery](/architecture/auto-discovery.md) — why no registration is needed.
