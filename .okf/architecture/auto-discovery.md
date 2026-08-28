---
type: Architecture Pattern
title: Auto-discovery via mkDefaultModule
description: Every `default.nix` in a mixin category directory calls `mkDefaultModule { dir = ./.; }`, which auto-imports every sibling `.nix` file — dropping a new file is enough to register it.
tags: [architecture, modules, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-28T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# What it does

`custom.lib.modules.mkDefaultModule { dir = ./.; } { … }` extends a module's `imports` list with every sibling `.nix` file in `dir`, excluding `default.nix` itself. Registration is by filesystem presence — dropping a new file into the right category directory is enough; no manual list to update. Implementation in `lib/modules/mkDefaultModule.nix`.

Every category `default.nix` under `hosts/mixins/` and `users/mixins/` is a one-liner:

```nix
{ custom, ... }: custom.lib.modules.mkDefaultModule { dir = ./.; } { }
```

Some directories pass a starter module (with its own `imports`, options, or config) as the second argument, merged with the auto-discovered files. See `users/mixins/default.nix` — it imports `sops-nix` and sets baseline `programs.git` config alongside auto-discovery.

# `exclude` admits a value sibling

An optional `exclude ? [ ]` list drops paths from the scan on top of `default.nix`. That is what lets an auto-discovering directory also hold a sibling that is a **value** rather than a module — otherwise it would be imported as one and fail. `modules/home/tidy/` keeps `timer.nix` (shared option block and timer-unit builder) out this way, and its two service modules `import ./timer.nix { inherit lib; }` themselves. Without it, a value sibling forces the whole directory onto a hand-written `imports` list, the form `tmux/`, `waybar/` and `rofi/` take. `modules/theme/` uses it for the other case: `nixos.nix` and `home.nix` are real modules, but must reach only the tree `mkClassModule` selects them for, not both.

# `importApply` variant

`mkDefaultModule` also accepts an optional `args` attrset. When present, each discovered file is imported via `lib.modules.importApply path args` instead of a bare path import, so child modules can receive extra parameters. Used in three places, all wrapping the call in a `lib.fix` fixed-point so `args = self`:

* `modules/nixos/default.nix` and `modules/home/default.nix` — for the flake-level auto-discovered modules.
* `users/mixins/desktop-environment/hyprland/default.nix` — for the hyprland module tree.

For the mechanics of the fixed-point wrapper, read those files; the OKF-worthy fact is that this variant exists and where.

# Also applies to `lib/`

`lib/default.nix` uses the same idea to expose every sibling file as an attribute. See [custom-lib](custom-lib.md).

# The sub-flakes are the exception

`apps/nix-schemes/` does **not** auto-discover: its `flake.nix` lists every module by hand under `nixosModules` / `homeModules`. A new file in `modules/home/` needs two registrations to reach a config — the export in `apps/nix-schemes/flake.nix`, then an entry in this repo's `modules/theme/home.nix` `imports`. Neither failure is loud; the module simply never loads and its options report as nonexistent.

# Related

* [mixin-pattern](mixin-pattern.md) — the shape of the files that get auto-discovered.
* [custom-lib](custom-lib.md) — the same idea applied to `lib/`.
