---
type: Architecture Pattern
title: Mixin pattern
description: Every reusable module declares one `enable` flag under `options.mixins.<category>.<name>`; hosts and users opt in from central `mixins.nix` files.
tags: [architecture, modules, convention]
timestamp: 2026-07-17T00:00:00Z
---

# Shape

Every leaf module follows the same shape:

```nix
{
  options.mixins.<category>.<name> =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "<name> config mixin";
    };

  config =
    let
      cfg = config.mixins.<category>.<name>;
    in
    lib.mkIf cfg.enable {
      # real config here
    };
}
```

Only the `enable` flag is exposed. Everything else lives inside the `config` block, gated by `lib.mkIf cfg.enable`. See [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) for the reasoning.

# Directory layout

| Domain | Location | Opt-in file |
|---|---|---|
| NixOS mixins | `hosts/mixins/{boot,desktop-environment,display-manager,hardware,networking,programs,services,virtualisation,…}/*.nix` | `hosts/<hostname>/mixins.nix` |
| Home-manager mixins | `users/mixins/{programs,services,desktop-environment,helpers,pwas}/*.nix` | `users/<username>/config/mixins.nix` |

Canonical minimal example: `users/mixins/programs/claude-code.nix`. Real-world opt-in files: `hosts/HAL9000/mixins.nix` (NixOS side) and `users/joker9944/config/mixins.nix` (home-manager side).

# Where per-host config lives

Config that isn't reusable — per-host quirks, monitor layouts, keyboard layout choices — does *not* go in a mixin. It lives directly in `hosts/<host>/default.nix` (NixOS) or `users/<user>/hosts/<host>/default.nix` (home-manager), alongside the enable list, as a plain assignment to the upstream option.

# Cross-tree link

`mkHomeConfiguration` re-exports `osConfig.mixins.desktopEnvironment` into the home-manager config (see `users/joker9944/default.nix`), so the system-side DE choice propagates automatically. This is the only place the two trees share state directly — everything else is set independently on each side.

# Related

* [auto-discovery](auto-discovery.md) — how mixin files register themselves.
* [entry-points](entry-points.md) — where the trees get evaluated.
* [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) — why only `enable` is exposed.
