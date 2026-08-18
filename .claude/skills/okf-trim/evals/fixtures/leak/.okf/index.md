---
okf_version: "0.2"
---

# Fixture bundle: leak

Frozen pre-trim excerpt of the nix-config knowledge bundle.

# Workflows

* [rebuild](workflows/rebuild.md) — How to rebuild NixOS and home-manager from this flake.
* [track-upstream-blockers](workflows/track-upstream-blockers.md) — krank checks whether workaround issue links are still open.

# Architecture

* [profiles](architecture/profiles.md) — A profile is a reusable host role: a named set of mixin enables shared by a class of machines.

# Decisions

* [host-profiles](decisions/host-profiles.md) — Hosts select exactly one high-level profile; orthogonal roles are mixins.
