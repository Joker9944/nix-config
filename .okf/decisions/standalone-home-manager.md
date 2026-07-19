---
type: Decision
title: Standalone home-manager
description: Home-manager is built as a separate flake output (`homeConfigurations`) and invoked directly, not imported as a NixOS module. But it still inherits pkgs + specialArgs from the paired NixOS config.
tags: [decision, home-manager, architecture]
timestamp: 2026-07-17T00:00:00Z
---

# The choice

`flake.nix` exposes both `nixosConfigurations.<host>` and `homeConfigurations.<user>@<host>`. Users activate the environment with `home-manager switch --flake .#<user>@<host>`, not through `nixos-rebuild`.

The two are still coupled: `mkHomeConfiguration` accepts the built `nixosConfigurations.<host>` as its first argument and inherits both `pkgs` and `specialArgs` from it. That's how `custom.lib`, `custom.assets`, and the overlays stay in sync across both trees, and how `osConfig` is available inside home-manager modules.

# Why

* **Faster iteration on user config.** A `home-manager switch` doesn't rebuild the system; only user-owned outputs get touched. That's the common case when hacking on a program mixin.
* **User activation on a non-repo-owned NixOS host.** The standalone form works even if someone else's system config is running underneath — useful when trying out this config on a foreign machine.
* **Cleaner failure mode.** A broken home-manager activation doesn't brick the system boot; the login shell is still available.

# Trade-off accepted

* **Two rebuild commands** instead of one — you need to remember to run both after touching shared concerns.
* **Cross-tree state has to be threaded manually.** For example, `users/joker9944/default.nix` re-exports `mixins.desktopEnvironment` from `osConfig` so a DE choice made system-side reaches the user-side; that's an explicit hand-off, not automatic.

# Related

* [architecture/entry-points](/architecture/entry-points.md) — how `mkHomeConfiguration` inherits from `nixosConfigurations`.
* [workflows/rebuild](/workflows/rebuild.md) — the two-command flow.
