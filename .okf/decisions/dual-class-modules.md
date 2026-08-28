---
type: Decision
title: Dual-class modules
description: A module loaded into both trees keeps its shared core in `modules/global/` and one glue module per tree; the module system's `_class` argument makes that split a choice rather than a constraint, and the dendritic pattern is not adopted.
tags: [decision, modules, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-28T00:00:00Z
---

# The rule

A feature that configures both trees is three modules: a class-agnostic core under `modules/global/`,
exported under its own key in both `nixosModules` and `homeModules`, plus a glue module in each of
`modules/nixos/` and `modules/home/`. The theme is the only instance;
[/architecture/module-layout](/architecture/module-layout.md) has the constraints the core is subject
to and what each glue module owns.

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

`custom.lib.modules.mkClassModule` is that branch as a helper: it takes `_class` and a module per
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
  it rejects `specialArgs` pass-through, which is how both constructors in
  [/architecture/entry-points](/architecture/entry-points.md) thread `custom.*`, `inputs` and
  `osConfig`.
* `import-tree`, its auto-import half, is `mkDefaultModule` here, which also threads `args` through
  `importApply`.
* It cannot be piloted on one module: flake-parts replaces the flake's output builder wholesale.
* Its remaining half — cross-file merge into one feature name — has no consumer. Nothing contributes
  to the theme from two files across classes.

# Trade-off accepted

Reading the theme means opening three directories. `_class` would collapse them; the split is kept
because it names each tree's contribution at the flake output rather than inside a conditional.
`apps/nix-schemes` splits the same way, so the two move together.
