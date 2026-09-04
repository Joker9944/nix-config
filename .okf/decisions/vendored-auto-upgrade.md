---
type: Decision
title: Vendored home-manager auto-upgrade
description: The local services.home-manager.autoUpgrade module displaces the upstream one with disabledModules, because upstream drives home-manager switch from a local checkout and this repo upgrades from a remote flake ref.
tags: [decision, home-manager, systemd, updates]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-04T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# The rule

`modules/home/public/custom/auto-upgrade/` declares `services.home-manager.autoUpgrade` itself and unloads
upstream's implementation with `disabledModules = [ "services/home-manager-auto-upgrade.nix" ]`.
Both exist in the pinned revision; the local one wins deliberately.

# Why

Upstream's module resolves the configuration from a **directory on disk** — it hard-fails when
`$FLAKE_DIR/flake.nix` is absent, then `cd`s there and runs `home-manager switch --flake .`. This
repo upgrades from a remote ref (`flake = "github:Joker9944/nix-config"`, set once in
`modules/nixos/mixins/services/maintenance.nix` and inherited by the home-manager side), so no checkout
exists on the machine to point `flakeDir` at. Passing `--flake <uri>` through `flags` does not help:
the existence check runs first.

The local module also orders the unit after `network-online.target`, which upstream omits — an
unattended 04:00 job that fetches from GitHub depends on it.

# Not reasons

* **The timer knobs.** `randomizedDelaySec` and `fixedRandomDelay` have no upstream equivalent but
  sit at their defaults and nothing sets them; upstream hardcodes the `Persistent = true` that is
  wanted anyway.
* **Failure notification.** `notification-service.nix` only attaches `Unit.OnFailure` to the
  `home-manager-auto-upgrade` unit, which upstream names identically. It would survive either way.

# Trade-off accepted

* **A vendored copy tracks nothing.** Upstream fixes to its module never arrive here, and the local
  copy carries the nixpkgs `auto-upgrade.nix` option vocabulary rather than home-manager's.
* **Two option surfaces with one name.** `services.home-manager.autoUpgrade` means the local shape,
  so upstream documentation for that path is wrong here.

Revisit if upstream accepts a flake URI where it currently wants a directory, or grows an equivalent
escape hatch. Nothing tracks that today — the related pull requests are all closed and no feature
request is open. Filing one upstream would put the condition under
[workflows/track-upstream-blockers](/workflows/track-upstream-blockers.md) instead of leaving it to
memory.

# Related

* [standalone-home-manager](standalone-home-manager.md) — why the home-manager side upgrades on its
  own rather than through `nixos-rebuild`.
* [workflows/dependency-updates](/workflows/dependency-updates.md) — the other update channels, none
  of which touch the machine's own scheduled upgrade.
