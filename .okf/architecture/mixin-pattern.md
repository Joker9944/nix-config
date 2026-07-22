---
type: Architecture Pattern
title: Mixin pattern
description: Every reusable module declares one `enable` flag under `options.mixins.<category>.<name>`; hosts and users opt in from central `mixins.nix` files.
tags: [architecture, modules, convention]
timestamp: 2026-07-22T00:00:00Z
---

# Shape

Only the `enable` flag is exposed; everything else is gated behind it. See [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) for the reasoning. Both trees (`users/mixins/` and `hosts/mixins/`) now use the `mkMixinModule` sugar; the manual shape survives only in the exceptions listed below.

## `mkMixinModule` sugar

Each category `default.nix` reads `config` once and threads a `mkMixinModule` helper to its leaves via `importApply` (see [custom-lib](custom-lib.md)). Leaves are two-layer: the outer arg receives the threaded helper, the inner arg is the normal module arg-set (drop the inner layer entirely when the body needs no module args):

```nix
{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "atuin" {
  # real config here — no option decl, no lib.mkIf
}
```

`mkMixinModule "<name>"` declares `mixins.<prefix>.<name>.enable` and wraps the body in `lib.mkIf`. `<name>` is the option segment, **not necessarily the filename** (hm: `nix-helper.nix` → `"nix"`, `vscode/` → `"vscodium"`, `1password.nix` → `"_1password"`; NixOS: `dualboot-windows.nix` → `"windowsSupport"`, `1password.nix` → `"_1password"`). The prefix comes from the aggregator (`programs/` → `[ "programs" ]`, `desktop-environment/` → `[ "desktopEnvironment" ]`, `display-manager/` → `[ "displayManager" ]` — camelCase, so it can't be derived from the dir name).

**Aggregator wiring.** The top-level `default.nix` of each tree (`users/mixins/default.nix`, `hosts/mixins/default.nix`) reads `config` once and builds a `lib.fix`ed `mkDefaultMixinModule` helper that it threads to every child. Category aggregators call `mkDefaultMixinModule { dir = ./.; prefix = [ … ]; } { }`; this re-threads `mkDefaultMixinModule` (for nested aggregators) plus a prefix-bound `mkMixinModule` (for leaves).

Exceptions keep the manual shape (below) plus an outer `_:` absorb layer, because the sugar only declares `enable`: mixins with **extra options** (hm `pwas/*`, `1password` with `vault`; NixOS `keymap` with `type`, `services/maintenance` with `flake`, `hardware/disko`), a **custom enable default** (hm `steam`; NixOS `boot`, whose `default.nix` is also the category aggregator + carries `secureBoot`), **partial gating**, or their **own internal fan-out** (`hyprland` on both trees).

## Manual shape (exceptions only)

```nix
_:
{ lib, config, ... }:
{
  options.mixins.<category>.<name>.enable = lib.mkEnableOption "<name> config mixin";

  config = lib.mkIf config.mixins.<category>.<name>.enable {
    # real config here
  };
}
```

Atomicity: once an aggregator threads `args`, **every** child in that dir must be two-layer (`importApply` feeds the args to all of them) — convert an aggregator and its leaves together.

# Directory layout

| Domain | Location | Opt-in file |
|---|---|---|
| NixOS mixins | `hosts/mixins/{boot,desktop-environment,display-manager,hardware,networking,programs,services,virtualisation,…}/*.nix` | `hosts/<hostname>/mixins.nix` |
| Home-manager mixins | `users/mixins/{programs,services,desktop-environment,helpers,pwas}/*.nix` | `users/<username>/config/mixins.nix` |

Canonical minimal example: `users/mixins/programs/claude-code/default.nix`. Real-world opt-in files: `hosts/HAL9000/mixins.nix` (NixOS side) and `users/joker9944/config/mixins.nix` (home-manager side).

For the on-disk shape once a mixin grows beyond a single `.nix` file, see [module-layout](module-layout.md) — the folder + `files/` conventions apply to every module in the repo, not just mixins.

# Where per-host config lives

Config that isn't reusable — per-host quirks, monitor layouts, keyboard layout choices — does *not* go in a mixin. It lives directly in `hosts/<host>/default.nix` (NixOS) or `users/<user>/hosts/<host>/default.nix` (home-manager), alongside the enable list, as a plain assignment to the upstream option.

# Cross-tree link

`mkHomeConfiguration` re-exports `osConfig.mixins.desktopEnvironment` into the home-manager config (see `users/joker9944/default.nix`), so the system-side DE choice propagates automatically. This is the only place the two trees share state directly — everything else is set independently on each side.

# Related

* [module-layout](module-layout.md) — folder/`files/` conventions for multi-file modules (applies repo-wide, not just to mixins).
* [auto-discovery](auto-discovery.md) — how mixin files register themselves.
* [entry-points](entry-points.md) — where the trees get evaluated.
* [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) — why only `enable` is exposed.
