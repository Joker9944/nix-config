---
type: Decision
title: Mixins expose only `enable`
description: Every mixin under modules/nixos/mixins/ and modules/home/mixins/ declares exactly one option (`enable = mkEnableOption "…"`). Any per-host or per-user knob lives outside the mixin as a plain override.
tags: [decision, modules, convention]
generated:
  by: claude-code/claude-opus-4-8
  at: 2026-09-04T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# The rule

Mixin option namespace is capped at a boolean:

```nix
options.mixins.<category>.<name> = { enable = mkEnableOption "…"; };
```

Configuration values that differ per host or per user do **not** get lifted into `mkOption` declarations on the mixin. They go into `modules/nixos/hosts/<host>/default.nix` (NixOS) or `modules/home/users/<user>/hosts/<host>/default.nix` (home-manager) as direct assignments to the upstream option — `wayland.windowManager.hyprland.settings.monitor = […]`, `programs.git.settings.user = { … }`, etc.

# Why

* **Zero-cost enable/disable.** A host's `mixins.nix` reads like a manifest — one glance tells you what's on. Mixing config with enable flags in the same tree makes the manifest muddy.
* **No option-name real estate to maintain.** Custom `mkOption` declarations create a second surface area to keep synced with upstream; when upstream renames or restructures, the wrapper drifts. Direct pass-through assignments break loudly instead.
* **Locality of override.** A quirk that belongs to one host (HAL9000's monitor layout, wintermute's `services.xserver.xkb.layout = "ch"`) is visible in that host's directory rather than hidden in a shared mixin.
* **The mixin stays a canonical baseline.** Enabling it delivers a sensible default; anything beyond that is a deliberate deviation the caller writes explicitly.

# Trade-off accepted

* **Some duplication is possible** across hosts when both want the same non-default tweak. The convention is to accept it until a genuine third case appears, then promote the pattern into a helper or into the mixin's default block. The disk layout is such a helper (`flake.lib.disko`) rather than a mixin — a *parametrized template* is a function, not an `enable` flag; see [architecture/custom-lib](/architecture/custom-lib.md).

# Related

* [architecture/mixin-pattern](/architecture/mixin-pattern.md) — the shape this rule constrains.
* [workflows/add-mixin](/workflows/add-mixin.md) — where the rule bites when adding a new mixin.
