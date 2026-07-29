---
type: Decision
title: One profile per host; multi-role is a mixin concern
description: Hosts select exactly one high-level profile via a `profile` string; orthogonal roles are mixins, not a profile list, and a profile must stay shared across a class of machines.
tags: [decision, profiles, hosts]
timestamp: 2026-07-29T00:00:00Z
---

# Decision

A host selects **one** profile, named by a `profile` string in its flake record and resolved by `mkNixosConfiguration` to `hosts/profiles/<profile>.nix` (see [architecture/profiles](/architecture/profiles.md)). Profiles are **high-level roles shared by a class of machines**; a profile that would serve a single host is forbidden — that config is a host delta.

# Rejected: a profile *list* per host

The tempting generalization is `profiles = [ … ]`, so a machine can stack orthogonal roles — a server that is a k8s worker *and* a NAS. Rejected because:

* It re-opens composition in two places at once — `imports` chains *inside* profiles (IS-A) **and** a set union at the flake (HAS-A). That is the "mixin of mixins" tangle the [enable-flag-mixins](enable-flag-mixins.md) purity pass just removed one layer down.
* Modelling role *inheritance* (who imports `base`, how deep the chain runs) is OOP semantics grafted onto the module system; each added axis makes the profile graph harder to reason about than the flat mixin list beneath it.

The orthogonal capabilities that motivated a list — k8s node / control-plane / longhorn / NAS — are **capabilities**, and capabilities are [mixins](/architecture/mixin-pattern.md). A host that plays several such roles enables several mixins; it still has one profile (or none). Composition then lives in exactly one place (the mixin enable list) and one shape (flat, binary).

# Rejected: builder-injected `base`

`base` could be added unconditionally by `mkNixosConfiguration` so every host inherits it. Rejected in favour of reaching `base` through the profile's own `imports` chain (`hyprland-desktop` → `desktop` → `base`): inheritance should be *structured and visible in the profile files*, not an invisible default in the builder. A host with no profile therefore gets no base — deliberately.

# Why "high-level, never per-machine"

Without the rule, the profile layer decays into a second host layer: each machine grows a `foo-host` profile and the indirection buys nothing. The test is concrete — *would a second machine select this profile unchanged?* If not, it is a host delta (`hosts/<host>/mixins.nix` or `default.nix`), not a profile. Prefer few broad roles refined by a short `imports` chain over many narrow ones.

# Related

* [architecture/profiles](/architecture/profiles.md) — the is-state this decision governs.
* [enable-flag-mixins](enable-flag-mixins.md) — the sibling purity decision one layer down; multi-role composition is deliberately pushed here.
