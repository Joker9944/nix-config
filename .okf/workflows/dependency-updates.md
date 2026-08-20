---
type: Playbook
title: Dependency updates
description: The channels that keep dependencies current — Renovate for GitHub Actions digests, nix-flake-update.yaml for the lock files, nix-packages-update.yaml for pkgs/*.nix, nix-schemes-update.yaml for the vendored schemes, and a manual release bump.
tags: [workflow, ci, renovate, flake, updates]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-20T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# Channels

| What | Driver | Cadence | Lands how |
|---|---|---|---|
| GitHub Actions digest pins | Renovate | weekends | automerged, checks skipped |
| every `flake.lock` | `.github/workflows/nix-flake-update.yaml` | daily 03:00 | automerged PR `ci/nix-flake-update` |
| `pkgs/*.nix` versions | `.github/workflows/nix-packages-update.yaml` | Tue/Sat 03:30 | automerged PR |
| `apps/nix-schemes/vendor/schemes/` | `.github/workflows/nix-schemes-update.yaml` | monthly, 1st 04:00 | automerged PR `ci/nix-schemes-update` |
| `nixpkgs` + `home-manager` release | manual | May and November | [release-upgrade](release-upgrade.md) |

Renovate runs as the hosted Mend app; its config is `.github/renovate.json5` and covers actions
only — see [decisions/renovate-scope](/decisions/renovate-scope.md) for why nothing nix is routed
through it. `ignoreTests: true` on the automerge rule is safe for the same reason: every Renovate
PR here is an action digest, which the flake gate has no opinion about.

All three nix workflows end in `.github/composites/update-pr`, which owns the PR plumbing — app token,
pull request, automerge — and the CI identity behind it
([decisions/ci-identity](/decisions/ci-identity.md)). The step that produces the diff stays in the
workflow rather than the composite, so it can be a `run:` or a curated action; the composite only
cares that the working tree changed.

`nix-flake-update.yaml` discovers flake directories by `find`, so the root flake and the two under
`apps/` are all refreshed in one run, one commit per lock file. `nix-packages-update.yaml` stays a
workflow rather than a Renovate manager because `nix-update` recomputes the FOD `hash` alongside
`version`; Renovate has no equivalent. `nix-schemes-update.yaml` regenerates a vendored tree rather
than bumping a pin, so it runs the sub-flake's own app from `apps/nix-schemes` and opens no PR in a
month where upstream changed nothing — see
[decisions/vendored-schemes](/decisions/vendored-schemes.md) for why that tree is refreshed on a
schedule instead of checked during evaluation.

`.github/workflows/nix-flake-check.yaml` runs `nix flake check` on every PR to `main`, and again on
the push that merges it — the second run is a cache seed, not a gate
([decisions/ci-nix-installer](/decisions/ci-nix-installer.md)). It is the gate every nix update PR
waits on — which only holds because the app token triggers `on: pull_request`; `GITHUB_TOKEN` would
not, and automerge would hang.

# Related

* [decisions/ci-identity](/decisions/ci-identity.md) — who the update PRs are authored as.
* [decisions/renovate-scope](/decisions/renovate-scope.md) — why Renovate is limited to actions.
* [release-upgrade](release-upgrade.md) — the manual bump the table's last row points at.
* [decisions/release-policy](/decisions/release-policy.md) — why the two release inputs are pinned
  and move in lockstep.
* [rebuild](rebuild.md) — verifying an update locally before merging.
