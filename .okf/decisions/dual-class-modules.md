---
type: Decision
title: Dual-class modules
description: A module loaded into both trees lives in one feature directory under `modules/` and selects its tree-specific half on the `_class` module argument; the dendritic pattern is not adopted.
tags: [decision, modules, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-31T00:00:00Z
---

# The rule

A feature that configures both trees is **one directory** under `modules/`, exported under its own
key in both `nixosModules` and `homeModules`. Its `default.nix` carries what the trees share and
dispatches to a per-tree branch file on `_class`; `mkDefaultModule`'s `exclude` keeps those branch
files out of leaf auto-discovery. `modules/theme/` is the only instance —
[/architecture/module-layout](/architecture/module-layout.md) has the constraints the shared body is
subject to and what each branch owns.

# `_class` is a module argument

`lib/modules.nix` passes `_class` into every module's argument set beside `lib`, `options` and
`config` — `"nixos"` from `nixos/lib/eval-config-minimal.nix`, `"homeManager"` from home-manager's
`modules/default.nix`. It is a plain argument, not `config`, so it is usable in `imports` position
without the recursion that reading `config` there would cause:

```nix
{ _class, lib, ... }:
{
  imports =
    lib.optional (_class == "nixos") ./nixos.nix
    ++ lib.optional (_class == "homeManager") ./home.nix;
}
```

One module value in both output keys then selects its own glue, which is what makes the three-way
split a choice. `mkDefaultModule`'s `exclude` keeps such branch files out of leaf auto-discovery —
see [/architecture/auto-discovery](/architecture/auto-discovery.md).

`flake.lib.modules.mkClassModule` is that branch as a helper: it takes `_class` and a module per
class, keyed by the class name the module system uses (`homeManager`, not `home`). A class with no
key is a no-op, so a module configuring one tree needs no empty branch for the other; a key naming
no class throws, which is what still catches a typo once the no-op removes the missing-key signal.

# Why not the dendritic pattern

[The dendritic pattern](https://github.com/mightyiam/dendritic) makes every non-entry file a module
of a top-level configuration — normally flake-parts — which stores lower-level modules as option
values under `flake.modules.<class>.<name>`. It does not make one module body evaluate two ways: a
file declares both class attributes, so the gain is colocation and cross-file merge, not fewer
bodies. Four reasons it is not adopted:

* Two of its named anti-patterns are this repo's architecture. It rejects `enable` options that
  gate an import, which is [/decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) and the
  structural exclusivity argument in [/architecture/mixin-pattern](/architecture/mixin-pattern.md);
  it rejects `specialArgs` pass-through, and `osConfig` is exactly that in
  [/architecture/entry-points](/architecture/entry-points.md).
* `import-tree`, its auto-import half, is `mkDefaultModule` here, which also threads `args` through
  `importApply`.
* It cannot be piloted on one module: flake-parts replaces the flake's output builder wholesale.
* Its remaining half — cross-file merge into one feature name — has no consumer. Nothing contributes
  to the theme from two files across classes.

# Trade-off accepted

Dispatch is invisible from the flake output: `nixosModules.theme` and `homeModules.theme` are the
same value, and only the module's own body says the trees get different halves. The split that made
it visible cost three directories to read instead of one. `apps/nix-schemes` still splits across
`modules/{global,home,nixos}/` — it publishes two module bundles rather than one dual-class module,
so it has nothing to dispatch inside, and it cannot reach `flake.lib` regardless.
