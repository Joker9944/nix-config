---
type: Architecture Pattern
title: Auto-discovery via mkDefaultModule
description: Every `default.nix` in a mixin category directory calls `mkDefaultModule { dir = ./.; }`, which auto-imports every sibling `.nix` file — dropping a new file is enough to register it.
tags: [architecture, modules, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-04T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# What it does

`flake.lib.modules.mkDefaultModule { dir = ./.; } { … }` extends a module's `imports` list with every sibling `.nix` file in `dir`, excluding `default.nix` itself. Registration is by filesystem presence — dropping a new file into the right category directory is enough; no manual list to update. Implementation in `lib/modules/mkDefaultModule.nix`.

Every category `default.nix` under `modules/nixos/mixins/` and `modules/home/mixins/` is a one-liner over the threaded aggregator helper (see [mixin-pattern](mixin-pattern.md#mkmixinmodule-sugar)):

```nix
{ mkDefaultMixinModule, ... }: mkDefaultMixinModule { dir = ./.; prefix = [ "programs" ]; } { }
```

Directories outside the mixin trees call the lib directly:

```nix
{ flake, ... }@args: flake.lib.modules.mkDefaultModule { dir = ./.; inherit args; } { }
```

Some directories pass a starter module (with its own `imports`, options, or config) as the second argument, merged with the auto-discovered files. See `modules/home/mixins/default.nix` — it imports `sops-nix` and sets baseline `programs.git` config alongside auto-discovery.

# `exclude` admits a value sibling

An optional `exclude ? [ ]` list drops paths from the scan on top of `default.nix`. That is what lets an auto-discovering directory also hold a sibling that is a **value** rather than a module — otherwise it would be imported as one and fail. `modules/home/public/tidy/` keeps `timer.nix` (shared option block and timer-unit builder) out this way, and its two service modules `import ./timer.nix { inherit lib; }` themselves. Without it, a value sibling forces the whole directory onto a hand-written `imports` list, the form `rofi/` takes for `theme.rasi.nix`.

# `importApply` variant

`mkDefaultModule` also accepts an optional `args` attrset. When present, each discovered file is imported via `lib.modules.importApply path args` instead of a bare path import, so child modules can receive extra parameters. Used in:

* `modules/{nixos,home}/mixins/default.nix` — each wraps the call in a `lib.fix` fixed-point to thread `mkDefaultMixinModule` down the tree.
* the hyprland aggregators (`modules/{nixos,home}/mixins/desktop-environment/hyprland/default.nix`) — same fixed-point move for their own helpers.
* `modules/theme/default.nix` — threads a local `mkThemeModule` to the theme leaves.

For the mechanics of the fixed-point wrapper, read those files; the OKF-worthy fact is that this variant exists and where.

# The flake-level collector: `mkModules`

`flake.lib.modules.mkModules { dir, prefix, args }` is the sibling for flake *outputs*: it walks `modules/nixos/{hosts,profiles,public,users}` and `modules/home/{users,public}` and yields a flat attrset of modules keyed `<prefix>-<path-segments>` (`hosts-HAL9000`, `public-tidy`, `users-joker9944`). A directory holding a `default.nix` is one module; one without is a namespace whose name joins the key with `-`; duplicate keys throw at evaluation. `flake.nix` merges those sets with the two hand-placed keys `mixins` and `theme`, and the [entry-point](entry-points.md) constructors select from them.

# Also applies to `lib/`

`lib/default.nix` uses the same idea to expose every sibling file as an attribute. See [custom-lib](custom-lib.md).

# The sub-flakes are the exception

`apps/nix-schemes/` does **not** auto-discover: its `flake.nix` lists every module by hand under `nixosModules` / `homeModules`, and its `default` keys aggregate the whole list. This repo's `modules/theme/compat.nix` imports `<class>Modules.default` per tree, so a module listed there arrives without further registration — but forgetting the listing in `apps/nix-schemes/flake.nix` is silent: the module simply never loads and its options report as nonexistent.

# Related

* [mixin-pattern](mixin-pattern.md) — the shape of the files that get auto-discovered.
* [custom-lib](custom-lib.md) — the same idea applied to `lib/`.
