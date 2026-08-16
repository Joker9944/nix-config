---
type: Decision
title: util-lib split
description: General-purpose Nix helpers live in the standalone `apps/util-lib` flake as `libUtil`; `lib/` keeps only what touches the module system or this repo. A lib names itself `libSelf` and a foreign lib by its own name.
tags: [decision, lib, architecture]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-15T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# The choice

`lib/` is split in two. General-purpose helpers live in `apps/util-lib`, a flake with its own
tests that exports a single `libUtil` attrset. `lib/` keeps everything else. See
[/architecture/custom-lib.md](/architecture/custom-lib.md) for the resulting shape.

# The boundary

**Does it touch the module system?** Not "is it pure Nix". `nonNull` is a one-liner over
`lib.mkIf`, and `mkConditionalModule` needs nothing but nixpkgs `lib` — but both only mean
something to a module evaluation, so both stay in `lib/modules/`. What moved is the set that
would read identically in a repo with no NixOS in it: string, list and directory helpers.

The alternative boundary — reusability, "anything with no repo-specific dependency" — would
have dragged `mkMixinModule` along with them, and with it this repo's
`mixins.<prefix>.<name>.enable` convention. A "misc utility library" that encodes one repo's
option paths is not reusable, whatever its dependency graph says.

# Namespaces come from directories, nothing else

`mkLibNamespace` takes a directory and an argument set. Subdirectories become nested
namespaces through their own `default.nix`, which is the same one-liner at every depth.

An earlier draft let each `default.nix` also declare its own namespace path and the arg name
to inject under. Both were dropped. The fixed point is tied **once per flake**, in
`flake.nix`, and the resulting args thread down unchanged — so a leaf at any depth already
sees the whole tree, and a per-directory namespace declaration can only restate what the
directory name already says, or contradict it.

# Naming: `libSelf`, and foreign libs by name

A lib tree is injected into its own files as `libSelf`; a foreign lib arrives under its own
name — `libUtil`, `libSchemes`, `libMath`. One attrset, one name, no aliases.

`self` is unavailable for a lib because a flake already uses it for itself, and both land in
the same argument sets — `lib/configuration/mkNixosConfiguration.nix` takes the flake as
`flake`, so naming the lib `self` beside it reads backwards.

The rule binds in *every* position a lib is passed, not just module arguments — see
[/architecture/custom-lib.md](/architecture/custom-lib.md#argument-convention) for where that
lands.

Each lib nests under `lib.<name>` rather than exporting flat, so `inherit (inputs.x.lib)
libFoo` yields the same identifier the tree uses internally. `inputs.nix-math.lib.math` set
that shape; `libUtil` and `libSchemes` follow it.

# Consequences

* A lib reaches consumers as a plain argument (`custom.libUtil` in the mixin trees, a direct
  `libUtil` arg in `modules/`, `pkgs/` and the test runners), not as a flake output of this
  repo.
* Each flake locks separately. `apps/util-lib` follows the root's `nixpkgs` and `flake-utils`;
  `apps/nix-schemes` reaches its sibling with a relative `path:../util-lib` input, and the
  root `follows` it so the tree carries one instance.
* Adding an input to a sub-flake needs `nix flake update <input>` at the root — a plain
  `nix flake lock` keeps the stale node and reports the `follows` as targeting a
  non-existent input.
