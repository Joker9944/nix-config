---
type: Decision
title: Renovate handles GitHub Actions only
description: Renovate is scoped to action digest pins; flake.lock and pkgs/*.nix updates stay in GitHub Actions workflows because Renovate's nix manager cannot track ref-pinned inputs or resolve flake.lock node names.
tags: [decision, ci, renovate, flake, updates]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-12T00:00:00Z
---

# The rule

`.github/renovate.json5` carries no `nix` config. The manager ships `enabled: false` in its own
`defaultConfig`, so leaving it unset is what keeps it off — Renovate sees only `github-actions` (and
the npm deps under `apps/yas`). Everything nix is workflow-driven; see
[workflows/dependency-updates](/workflows/dependency-updates.md) for the channels.

# Why

Renovate's nix manager has been tried twice — enabled until 2025-07, then again in 2026-08 — and
reverted both times. Roughly a year apart, the same two defects in
`lib/modules/manager/nix/extract.ts` still stand:

* **Ref-pinned inputs get no version.** `currentValue` / `replaceString` are set only when
  `flake.nix` pins a full commit SHA. A `ref` — branch *or tag* — yields `lockedVersion` alone, so
  no update is ever raised and the manager has nothing in `flake.nix` to rewrite. The only lever
  left is `nix flake update`, which re-resolves the same ref. Every input here is ref-pinned, so
  tag pins like `disko`'s would sit frozen indefinitely. The sole exception is a special case for
  `NixOS/nixpkgs`, which gets `currentValue` unconditionally.
* **Lock nodes are matched by key, not resolved.** The extractor keeps a node when its *key* also
  appears as a root input *name*, instead of following `root.inputs[name] → node key`. Nix appends
  `_2` on collision, so a transitive dependency that claims the plain key wins: here Hyprland's
  `nixpkgs` (tracking `nixos-unstable`) is extracted as `nixpkgs`, while the real pin at node
  `nixpkgs_2` is skipped entirely. Any `matchDepNames: ["nixpkgs"]` rule therefore aims at the
  wrong input — and under `nixpkgs` versioning `nixos-unstable` sorts *below* dated releases, so
  Renovate reads that as an available upgrade.

Together these mean the release bump that
[release-policy](release-policy.md) depends on cannot be automated through Renovate at all, and the
majority of inputs reduce to what `lockFileMaintenance` already does — which a workflow does
without the config surface.

# Trade-off accepted

* **Two update systems.** Action digests come from Renovate; flake locks and package versions from
  `.github/workflows/`. The overlap is small enough that unifying is not worth the above.
* **No dependency dashboard for nix.** Flake input drift is visible only in the nightly PR diff.
* **The release bump stays manual.** Step 1 of [workflows/release-upgrade](/workflows/release-upgrade.md)
  is hand-edited rather than arriving as a PR.

Revisit if upstream sets `currentValue` from `original.ref` and resolves node names through
`root.inputs`.

# Related

* [workflows/dependency-updates](/workflows/dependency-updates.md) — the channels that replace it.
* [release-policy](release-policy.md) — the release pins Renovate reads from the wrong lock node.
