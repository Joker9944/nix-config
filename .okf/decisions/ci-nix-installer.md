---
type: Decision
title: CI installs Nix single-user with community actions
description: nix-setup uses nixbuild/nix-quick-install-action plus nix-community/cache-nix-action instead of the DeterminateSystems pair; the store is unprivileged, the cache is keyed on the lock files, and nix-flake-check runs on push to main to seed it.
tags: [decision, ci, nix, cache]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-21T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# The rule

`.github/composites/nix-setup` is the only place CI gets Nix. It installs
`nixbuild/nix-quick-install-action` — unprivileged, single-user, no daemon — and caches `/nix`
through `nix-community/cache-nix-action`, an `actions/cache` fork. Neither DeterminateSystems action
is used — a vendor choice, not a defect in the tooling.

The composite takes no inputs. `nix_conf` carries `keep-outputs` and `keep-env-derivations`, which
is what makes a restored store useful rather than a pile of unreferenced paths, plus
`allow-import-from-derivation = false`, the CI half of [no-ifd](no-ifd.md); the action appends
`extra-experimental-features = nix-command flakes` and `accept-flake-config = true` itself, so
neither is restated.

Three things follow from that shape:

* **The cache key hashes `**/flake.lock`, not `**/*.nix`.** Almost every PR here touches a `.nix`
  file with no effect on the store, and the upstream example's key would mint a fresh multi-GB
  entry each time. A key miss still restores the newest entry via `restore-prefixes-first-match`.
* **No `purge`.** GitHub deletes caches untouched for 7 days and evicts oldest-accessed past 10 GB,
  and these workflows are the repo's only cache consumers, so there is nothing to protect a budget
  from. `gc-max-store-size-linux` bounds each entry; purge would only add `actions: write` to every
  workflow, against [ci-identity](ci-identity.md).
* **`nix-flake-check` runs on push to `main`, not only on PRs.** GitHub scopes each cache entry to
  the ref that created it — a PR reads its own ref plus the base branch, never a sibling PR. Only a
  main-branch run seeds something every PR can restore, and the update workflows never build the
  pre-commit closure that the check spends its time on. An entry scoped to `refs/pull/N/merge` is
  readable only by a re-run of that same PR, so bot-authored PRs restore without saving — they
  automerge on first green and never re-run. Human PRs still save, because they do.

# Trade-off accepted

* **Builds are unprivileged.** The sandbox needs user namespaces rather than a root daemon. If a
  runner image restricts them, the fix is `sandbox = relaxed` in the composite's `nix_conf`.
* **Nix is upstream, not Determinate.** The version comes from the action's pinned set, so it lags
  a release the installer would have offered.
* **Every installer release is a major.** `nix-quick-install-action` tags majors only, so Renovate
  routes each one through dashboard approval instead of automerging it as a patch.
* **One extra run per merge.** The `push: [main]` run is redundant as a gate — the PR it came from
  already passed. It exists to write the cache.

# Related

* [workflows/dependency-updates](/workflows/dependency-updates.md) — the workflows this composite
  serves.
* [ci-identity](ci-identity.md) — why workflow `permissions` stay read-only.
* [renovate-scope](renovate-scope.md) — what keeps the action pins current.
