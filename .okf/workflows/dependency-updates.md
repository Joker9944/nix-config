---
type: Playbook
title: Dependency updates
description: The channels that keep dependencies current — Renovate for GitHub Actions digests, flake.lock, and the release bump; nix-packages-update.yaml for pkgs/*.nix.
tags: [workflow, ci, renovate, flake, updates]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-12T00:00:00Z
---

# Channels

| What | Driver | Cadence | Lands how |
|---|---|---|---|
| GitHub Actions digest pins | Renovate | weekends | automerged, checks skipped |
| `flake.lock` (all three flakes) | Renovate `lockFileMaintenance` | daily 03:00 | automerged once `nix-flake-check` passes |
| `nixpkgs` + `home-manager` release | Renovate, grouped as `nixos release` | when a release appears | approve on the dashboard, then a PR labelled `release-upgrade`, never automerged |
| `pkgs/*.nix` versions | `.github/workflows/nix-packages-update.yaml` | Tue/Sat 03:30 | automerged PR |

Renovate runs as the hosted Mend app; its config is `.github/renovate.json5`. `nix-update` stays a
workflow because it recomputes the FOD `hash` alongside `version` — Renovate has no equivalent.

`.github/workflows/nix-flake-check.yaml` runs `nix flake check` on every PR to `main`. It is the
gate the `flake.lock` automerge waits on, which is why `ignoreTests: true` is scoped to the
`github-actions` manager only.

# The release PR

The grouped `nixos release` PR is step 1 of [release-upgrade](release-upgrade.md) arriving
pre-done. `groupName` is load-bearing: [decisions/release-policy](/decisions/release-policy.md)
requires the two inputs to move together, and ungrouped Renovate would open one PR each.

# Renovate gotchas

* The `nix` manager ships `enabled: false` in its own `defaultConfig` — `nix.enabled` must be set
  explicitly.
* The extractor special-cases `NixOS/nixpkgs` onto `nixpkgs` versioning; nothing else gets it, so
  `home-manager`'s `release-<yy>.<mm>` needs `versioning: "nixpkgs"` set on the dep.
* Under that scheme `major` = YY and `minor` = MM, so `26.05` → `26.11` classifies as a **minor**.
  Release bumps therefore carry an explicit `automerge: false` rather than relying on
  `matchUpdateTypes`.
* Under that scheme `nixos-unstable` sorts *below* dated releases, so a dated branch reads as an
  upgrade from unstable.
* `currentDigest` is set only for inputs rev-pinned in `flake.nix`; everything else gets
  `lockedVersion` and is left to `lockFileMaintenance`. No input here is rev-pinned, so the manager
  raises no `digest` updates at all.
* `path` and `indirect` inputs are skipped by the extractor, so `./apps/yas` and
  `./apps/nix-schemes` need no rule. Sourcehut inputs (`nix-jail`) extract normally.
* A rule scoped to `matchManagers: ["nix"]` alone also matches `lockFileMaintenance` branches, so
  every nix rule here narrows with `matchUpdateTypes` or `matchDepNames`.

# Related

* [release-upgrade](release-upgrade.md) — what to do when the `nixos release` PR lands.
* [decisions/release-policy](/decisions/release-policy.md) — why the two release inputs are pinned
  and move in lockstep.
* [rebuild](rebuild.md) — verifying an update locally before merging.
