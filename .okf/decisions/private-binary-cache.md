---
type: Decision
title: Private binary cache for the desktop closures
description: CI builds the desktop closures on every lock-changing PR and pushes them to harmonia on mother, served as a tailnet service; the build doubles as the gate that nix flake check is not.
tags: [decision, ci, nix, cache]
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-11-17T00:00:00Z
---

# The rule

`.github/workflows/nix-closure-build.yaml` builds the `HAL9000` and `wintermute` toplevels and
their `joker9944@<host>` activation packages, one matrix leg each. It runs only when a PR changes
`flake.lock`, or on `workflow_dispatch`, joining the tailnet as `tag:ci` through Tailscale OIDC
federation. Each leg signs its closure, `nix copy`s it to mother over `ssh-ng`, and points a profile
under `/nix/var/nix/profiles/per-user/nix-cache/` at it.

The `nixCache` mixin on [mother](/hosts/nyx-cluster.md) serves that store with harmonia, bound to
a Unix socket and published as the tailnet service `svc:nix-cache`
(`https://nix-cache.stoat-herring.ts.net`). The desktop profile adds it as a substituter.

# Why

* **Desktops only.** Their closures miss upstream caches in a way the servers' don't — unfree
  packages Hydra never builds (IntelliJ, 1Password, Zoom, Spotify, fdk-aac ffmpeg) and local
  overrides (firefoxpwa, the codium openssh patch, the yas stack). A server building its own glue
  for an unattended upgrade costs nobody anything.
* **Private.** Most of the bytes are unfree and not redistributable. Harmonia has no auth, so the
  tailnet grant to `svc:nix-cache` is the access control.
* **Harmonia on a NixOS host, not attic in the cluster.** Attic is unversioned, and it answers
  single-chunk NAR requests with a redirect to a presigned URL on its S3 backend's in-cluster name,
  which no client resolves. Harmonia serves the store of the machine it runs on, so GC and
  optimise are the host's own `nix.gc` and `nix.optimise`; in a pod that would be rebuilt by hand.
* **An untrusted push user.** A trusted Nix user is root on mother. `nix-cache` is not trusted;
  the daemon accepts its paths because CI signs them with `nix-config-ci-1`, which mother trusts.
* **Retention is a profile per closure.** `nix-collect-garbage --delete-older-than` recurses into
  every directory under `/nix/var/nix/profiles`, so the 30-day `nix.gc` that every host runs also
  expires old pushes.
* **Priority 50.** `--substitute-on-destination` puts whole closures on mother; advertising less
  than cache.nixos.org's 40 would route every desktop download through it.
* **On the lock PR.** `nix flake check` only evaluates `nixosConfigurations`; building them is the
  first point at which upstream breakage surfaces, so the build is also the lock PR's gate. Store
  paths depend on derivations, not commits, so what the PR pushes is what the desktops fetch after
  the merge.

# Trade-off accepted

* **Config-only commits on `main` are not prebuilt.** They mostly change glue; a commit touching an
  override builds on the desktop first unless the workflow is dispatched.
* **A host may build before the cache fills** when the lock PR merges after the 04:00 upgrade.
* **mother stores upstream paths too.** Nothing filters what upstream already holds; mother's
  `/nix` has the room.

# Related

* [ci-nix-installer](ci-nix-installer.md) — why this workflow opts out of the actions cache.
* [workflows/dependency-updates](/workflows/dependency-updates.md) — the lock PR it gates.
