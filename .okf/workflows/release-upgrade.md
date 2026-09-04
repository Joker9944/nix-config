---
type: Playbook
title: Release upgrade — deferred changes
description: How deferred "do this at the next nixpkgs/home-manager release" changes are tracked via UPGRADE(<release>) code markers, and the steps to run at a release bump.
tags: [workflow, upgrade, nixpkgs, home-manager]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-16T00:00:00Z
---

# Trigger

A flake bump to a new nixpkgs / home-manager release (see
[decisions/release-policy](/decisions/release-policy.md)), or a workaround being added that can be
dropped or simplified once a newer release lands.

# The convention

Some code exists only because an upstream feature isn't in the *current* pinned release yet. Rather
than carry that knowledge in your head, mark the site with a greppable token that encodes the
release it can be revisited in:

```nix
# UPGRADE(26.11): drop this local renderer; home-manager unstable exposes the
# Hyprland Lua generator as a lib function.
```

Token shape: `UPGRADE(<target-release>)` — one of the four markers in
[architecture/comment-markers](/architecture/comment-markers.md), and the only one taking a release
rather than an id. The release in the parens is the *earliest* release at
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

   The dev shell's `hm-options` / `nixos-options` rebuild against the new pin on the next
   `direnv reload`. From here until the upgrade is done they are the only non-stale account of what
   the options are — surface and traps in `.claude/skills/{home-manager-options,nixos-options}/SKILL.md`.
2. `grep -rn 'UPGRADE(<new-release>)' .` — deterministic, and any older `UPGRADE(<older>)` tokens
   that are now ≤ the new release are also actionable.
3. Work each hit: apply the change and remove the marker. The comment at the site says what to do.
4. Rebuild and verify per [rebuild](rebuild.md).

# Related

* [decisions/release-policy](/decisions/release-policy.md) — the stable-nixpkgs / matching-hm policy
  that creates these version gaps in the first place.
* [rebuild](rebuild.md) — how to build and switch after applying an upgrade.
* [track-upstream-blockers](track-upstream-blockers.md) — the sibling convention, for code waiting on
  an upstream bug rather than on a release.
