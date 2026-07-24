---
type: Playbook
title: Release upgrade — deferred changes
description: How deferred "do this at the next nixpkgs/home-manager release" changes are tracked via UPGRADE(<release>) code markers, and the steps to run at a release bump.
tags: [workflow, upgrade, nixpkgs, home-manager]
timestamp: 2026-07-24T00:00:00Z
---

# Trigger

You are bumping this flake to a new nixpkgs / home-manager release (see
[decisions/release-policy](/decisions/release-policy.md)), or you are about to add a workaround
that can be dropped or simplified once a newer release lands.

# The convention

Some code exists only because an upstream feature isn't in the *current* pinned release yet. Rather
than carry that knowledge in your head, mark the site with a greppable token that encodes the
release it can be revisited in:

```nix
# UPGRADE(26.11): drop this local renderer; home-manager unstable exposes the
# Hyprland Lua generator as a lib function.
```

Token shape: `UPGRADE(<target-release>)`. The release in the parens is the *earliest* release at
which the change becomes possible. One marker per site, co-located with the code it concerns so the
"why is this weird" answer is right there.

NixOS cuts a release every **May and November**, so the only valid release strings are
`<yy>.05` and `<yy>.11` (e.g. `26.05`, `26.11`, `27.05`). Pick the target accordingly — there is
no `.06` or `.10`.

# Steps at a release bump

Only two inputs are pinned to a release; everything else follows `nixpkgs`/unstable.

1. Bump the two pinned inputs in `flake.nix` to the new release, then `nix flake update`:
   * `nixpkgs.url = "github:NixOS/nixpkgs/nixos-<new-release>"`
   * `home-manager.url = "github:nix-community/home-manager/release-<new-release>"`

   (Note the differing branch prefixes: `nixos-` for nixpkgs, `release-` for home-manager.)
   `nixpkgs-unstable` and the hyprland input are not release-pinned and need no change here.
2. `grep -rn 'UPGRADE(<new-release>)' .` — deterministic, and any older `UPGRADE(<older>)` tokens
   that are now ≤ the new release are also actionable.
3. Work each hit: apply the change and remove the marker. The comment at the site says what to do.
4. Rebuild and verify per [rebuild](rebuild.md).

# Related

* [decisions/release-policy](/decisions/release-policy.md) — the stable-nixpkgs / matching-hm policy
  that creates these version gaps in the first place.
* [rebuild](rebuild.md) — how to build and switch after applying an upgrade.
