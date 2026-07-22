---
type: Architecture Pattern
title: Packages — pkgs/ auto-discovery and a lean flake.nix
description: How the flake's package set is assembled from ./pkgs, and the convention that flake.nix stays thin — package logic lives in pkgs/, not inline in the flake.
tags: [architecture, flake, packages, convention]
timestamp: 2026-07-23T00:00:00Z
---

# Where packages live

Every flake package is defined under `./pkgs`. `pkgs/default.nix` builds the `packages.<system>`
set by listing the directory with `flake.lib.ls` (see [custom-lib](custom-lib.md)). `flake.nix`
just calls `import ./pkgs { inherit lib pkgs inputs; flake = self; }` and exposes the result.

# Two kinds of entry: file packages and subdir package-groups

`pkgs/default.nix` discovers in two passes, merged together:

1. **Top-level `.nix` files** (`types = [ "regular" ]`) → `pkgs.callPackage path { inherit
   flake; }`. Standard nixpkgs-style packages; filename (minus `.nix`) is the attribute name.
   They receive `flake` but **not** `inputs` — a pure package recipe shouldn't need flake
   context, and any extra arg is absorbed via `...`.
2. **Top-level subdirectories** (`types = [ "directory" ]`) → `import path args`, where `args`
   is everything `flake.nix` passed in (`flake`, `lib`, `pkgs`, **`inputs`**). Each such
   `default.nix` must **return an attrset of packages**, which is merged into the set.

So a file is one package; a subdirectory is a *group* of packages that needs flake-level
context. The options-query tools use the subdir form precisely because they read flake inputs:

```
pkgs/
├── freelens.nix          # file → one package (callPackage, flake only)
└── nix-options/          # subdir → an attrset of packages (gets full args, incl. inputs)
    ├── default.nix       # returns { hm-options; nixos-options; } — factory + JSON resolution
    └── files/
        └── nix-options.sh  # engine script, read via builtins.readFile
```

`nix-options/default.nix` reads `inputs.home-manager.packages.<system>.docs-json` and
`inputs.nixpkgs` (for a bare `eval-config`), builds both tools with an internal `mkOptionsTool`,
and returns them — none of the factory leaks into the `packages` output. Its engine script lives
under `files/`, per the [module-layout](module-layout.md) `files/`-for-payloads convention.

Why the split? `flake`/`self` does not reliably expose `.inputs`, so `inputs` is threaded into
`pkgs/default.nix` and handed to subdir modules via `args`; file packages stay pure nixpkgs
recipes. The implicit contract for the second pass: **a subdirectory's `default.nix` returns an
attrset of packages** — there is no `exclude`, so every top-level subdir is treated as a
package-group.

# Keep flake.nix lean

`flake.nix` is wiring, not implementation. Package definitions, helper factories, and their
scripts belong in `pkgs/` — never inline in the flake. When something package-shaped starts
accreting in `flake.nix` (a `let` block building a derivation, a `writeShellApplication`, a
vendored script), that's the signal to move it under `pkgs/` behind the discovery rule above.
The flake stays small and stable so it doesn't drift.

# Related

* [custom-lib](custom-lib.md) — `flake.lib.ls` and the rest of the auto-loaded `lib/`.
* [auto-discovery](auto-discovery.md) — the parallel mechanism for *module* trees
  (`mkDefaultModule`), as opposed to this package tree.
* [entry-points](entry-points.md) — the other things `flake.nix` wires up.
* [module-layout](module-layout.md) — the folder/`files/` convention for modules.
