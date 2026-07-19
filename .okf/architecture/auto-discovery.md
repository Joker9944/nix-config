---
type: Architecture Pattern
title: Auto-discovery via mkDefaultModule
description: Every `default.nix` in a mixin category directory calls `mkDefaultModule { dir = ./.; }`, which auto-imports every sibling `.nix` file — dropping a new file is enough to register it.
tags: [architecture, modules, convention]
timestamp: 2026-07-17T00:00:00Z
---

# What it does

`custom.lib.mkDefaultModule { dir = ./.; } { … }` extends a module's `imports` list with every sibling `.nix` file in `dir`, excluding `default.nix` itself. Registration is by filesystem presence — dropping a new file into the right category directory is enough; no manual list to update. Implementation in `lib/mkDefaultModule.nix`.

Every category `default.nix` under `hosts/mixins/` and `users/mixins/` is a one-liner:

```nix
{ custom, ... }: custom.lib.mkDefaultModule { dir = ./.; } { }
```

Some directories pass a starter module (with its own `imports`, options, or config) as the second argument, merged with the auto-discovered files. See `users/mixins/default.nix` — it imports `sops-nix` and sets baseline `programs.git` config alongside auto-discovery.

# `importApply` variant

`mkDefaultModule` also accepts an optional `args` attrset. When present, each discovered file is imported via `lib.modules.importApply path args` instead of a bare path import, so child modules can receive extra parameters. Used in three places, all wrapping the call in a `lib.fix` fixed-point so `args = self`:

* `modules/nixos/default.nix` and `modules/home/default.nix` — for the flake-level auto-discovered modules.
* `users/mixins/desktop-environment/hyprland/default.nix` — for the hyprland module tree.

For the mechanics of the fixed-point wrapper, read those files; the OKF-worthy fact is that this variant exists and where.

# Also applies to `lib/`

`lib/default.nix` uses the same idea to expose every sibling file as an attribute. See [custom-lib](custom-lib.md).

# Related

* [mixin-pattern](mixin-pattern.md) — the shape of the files that get auto-discovered.
* [custom-lib](custom-lib.md) — the same idea applied to `lib/`.
