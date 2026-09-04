---
type: Architecture Pattern
title: Mixin pattern
description: Every reusable module declares one `enable` flag under `options.mixins.<category>.<name>`; hosts and users opt in from central `mixins.nix` files.
tags: [architecture, modules, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-04T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# Shape

A mixin exposes exactly one option: **`enable`**. Everything it configures is gated behind that flag and set to a fixed baseline — per-host and per-user variation lives *outside* the mixin as a plain override (see [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) for the reasoning, and [Where per-host config lives](#where-per-host-config-lives)). Every leaf on both trees (`modules/home/mixins/`, `modules/nixos/mixins/`) is written with the `mkMixinModule` sugar; there is no hand-written `options`/`config`/`mkIf` boilerplate.

## `mkMixinModule` sugar

Each category `default.nix` reads `config` once and threads a `mkMixinModule` helper to its leaves via `importApply` (see [custom-lib](custom-lib.md)). Leaves are two-layer: the outer arg receives the threaded helper, the inner arg is the normal module arg-set (drop the inner layer entirely when the body needs no module args):

```nix
{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "atuin" {
  # real config here — no option decl, no lib.mkIf
}
```

`mkMixinModule "<name>"` declares `mixins.<prefix>.<name>.enable` and wraps the body in `lib.mkIf`. `<name>` is the option segment in **camelCase** and the filename its **kebab-case** form; [module-layout](module-layout.md#casing) owns that mapping and its exceptions. The prefix comes from the aggregator (`programs/` → `[ "programs" ]`, `desktop-environment/` → `[ "desktopEnvironment" ]`, `display-manager/` → `[ "displayManager" ]` — camelCase, so it can't be derived from the dir name; nested sub-categories compose, e.g. `boot/loader/` → `[ "boot" "loader" ]`).

**Aggregator wiring.** The top-level `default.nix` of each tree (`modules/home/mixins/default.nix`, `modules/nixos/mixins/default.nix`) reads `config` once and builds a `lib.fix`ed `mkDefaultMixinModule` helper that it threads to every child. Category aggregators call `mkDefaultMixinModule { dir = ./.; prefix = [ … ]; } { }`; this re-threads `mkDefaultMixinModule` (for nested aggregators) plus a prefix-bound `mkMixinModule` (for leaves). Atomicity: once an aggregator threads `args`, **every** child in that dir must be two-layer (`importApply` feeds the args to all of them), so add or convert an aggregator and its leaves together.

Two mixins are **aggregators** rather than plain leaves, but both still expose only `enable`: `boot` is a category over a nested, mutually-exclusive `loader/` sub-category (see [Mutually-exclusive categories](#mutually-exclusive-categories)), and `hyprland` (both trees) is a hand-rolled fan-out whose `enable` is the toggle while an internal per-host config surface (`style`, `binds`, `launcher`, `terminal`, …) hangs under its namespace. `mixins.*` carries more than an `enable` in exactly two places: that hyprland surface, and `mixins.programs.steam.resolution` (NixOS side), which feeds gamescope's output flags.

## Mutually-exclusive categories

Some categories are "enable at most one leaf." The bootloaders under `modules/nixos/mixins/boot/loader/` (`limine`, `systemdBoot`) are ordinary `mkMixinModule` leaves; exclusivity is enforced **structurally** by an assertion in the sub-category aggregator (`boot/loader/default.nix`) that derives the loader set from the namespace instead of a hardcoded list:

```nix
assertion = lib.count (l: l.enable) (lib.attrValues config.mixins.boot.loader) <= 1;
```

Dropping a new leaf into `loader/` auto-registers it in the count — nothing to update. Hosts pick with `mixins.boot.loader.<name>.enable = true`.

`desktopEnvironment` (gnome/hyprland/kde-plasma) and `displayManager` are the same pick-one shape but rely on convention — no assertion. Prefer this leaf-per-variant category over an `enable + type` enum: an enum centralizes every variant's config behind a switch and reintroduces an option beyond `enable`, whereas leaves decompose into files and keep the constraint in the category shape.

Themes are the same pick-one shape but sit outside both mixin trees, under `custom.themes.<name>.enable` — see [module-layout](module-layout.md#picking-a-theme).

# Directory layout

| Domain | Location | Opt-in file |
|---|---|---|
| NixOS mixins | `modules/nixos/mixins/{boot,desktop-environment,display-manager,hardware,networking,programs,services,virtualisation,…}/*.nix` | `modules/nixos/hosts/<hostname>/mixins.nix` |
| Home-manager mixins | `modules/home/mixins/{programs,services,desktop-environment,pwas}/*.nix` | `modules/home/users/<username>/config/mixins.nix` |

Canonical minimal example: `modules/home/mixins/programs/claude-code/default.nix`. Real-world opt-in files: `modules/nixos/hosts/HAL9000/mixins.nix` (NixOS side) and `modules/home/users/joker9944/config/mixins.nix` (home-manager side).

On the NixOS side the bulk of a host's enables comes from its **[profile](profiles.md)** — a role selected by the `profile` string in the flake record — and `modules/nixos/hosts/<host>/mixins.nix` holds only the per-host deltas on top. The home-manager side has no profile layer, so its `mixins.nix` is the full enable list.

For the on-disk shape once a mixin grows beyond a single `.nix` file, see [module-layout](module-layout.md) — the folder + `files/` conventions apply to every module in the repo, not just mixins.

# Where per-host config lives

Config that isn't reusable — per-host quirks, monitor layouts, keyboard layout choices — does *not* go in a mixin. It lives directly in `modules/nixos/hosts/<host>/default.nix` (NixOS) or `modules/home/users/<user>/hosts/<host>/default.nix` (home-manager), alongside the enable list, as a plain assignment to the upstream option.

Config that *is* reusable across a class of machines — the enable set that defines "a desktop", "a server" — goes one level up, in a **[profile](profiles.md)**, not copied into each host's `mixins.nix`. The three tiers: a mixin is one capability, a profile is a role (a shared set of mixin enables), a host holds only its deltas.

# Cross-tree link

`modules/home/users/joker9944/default.nix` re-exports `osConfig.mixins.desktopEnvironment`, `osConfig.mixins.programs.steam.enable` and `osConfig.custom.themes` into the home-manager config, so those system-side choices propagate automatically. This is the only place the two trees share state directly — everything else is set independently on each side.

# Related

* [profiles](profiles.md) — the role layer above mixins; a profile is a shared set of these enable flags.
* [module-layout](module-layout.md) — folder/`files/` conventions for multi-file modules (applies repo-wide, not just to mixins).
* [auto-discovery](auto-discovery.md) — how mixin files register themselves.
* [entry-points](entry-points.md) — where the trees get evaluated.
* [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) — why only `enable` is exposed.
