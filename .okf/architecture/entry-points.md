---
type: Architecture Pattern
title: Entry points — mkNixosConfiguration & mkHomeConfiguration
description: The two constructors called from flake.nix that assemble every host system and every home-manager configuration.
tags: [architecture, flake, entry-point]
timestamp: 2026-07-17T00:00:00Z
---

# `mkNixosConfiguration`

Defined in `lib/mkNixosConfiguration.nix`. Assembles a `nixosSystem` from three sources:

1. `hosts/mixins/` — the reusable NixOS mixin tree.
2. `hosts/<hostname>/` — per-host modules (`default.nix`, `mixins.nix`, `disks.nix`, `hardware-configuration.nix`, …). Auto-loaded via `mkDefaultModule`.
3. `users/<username>/nixos/` for each username in the host record — user-owned system-level tweaks.

Also injects every module in `flake.nixosModules.*` (source: `modules/nixos/`) and the flake's overlays.

`specialArgs` provides:

* `inputs` — the flake inputs.
* `custom.lib` — the loaded `lib/` (see [custom-lib](custom-lib.md)).
* `custom.config` — the host record itself (`system`, `hostname`, `usernames`, `resolution`, …).
* `custom.assets` — packages from the `nix-assets` flake input.

# `mkHomeConfiguration`

Defined in `lib/mkHomeConfiguration.nix`. Builds a **standalone** home-manager configuration — home-manager is not a NixOS module here (see [decisions/standalone-home-manager](/decisions/standalone-home-manager.md)). Inherits `pkgs` and `specialArgs` from the paired NixOS configuration, so both trees stay in lockstep.

Sources:

1. `users/mixins/` — the reusable home-manager mixin tree.
2. `users/<username>/` — user-owned modules (`default.nix`, `config/`, `hosts/<hostname>/`, `nixos/`). Auto-loaded.
3. Every module in `flake.homeModules.*` (source: `modules/home/`).

Also exposes `osConfig` in `extraSpecialArgs`, so home-manager modules can read the paired NixOS config. Used, for example, by `users/joker9944/default.nix` to inherit `osConfig.mixins.desktopEnvironment` and by `users/joker9944/hosts/HAL9000/default.nix` to read `osConfig.programs.steam.package`.

# How they're called

`flake.nix` pipes a list of host records through `lib.map` and `lib.listToAttrs`. `nixosConfigurations` is keyed by `hostname`. `homeConfigurations` is keyed by `<username>@<hostname>` and passes the already-built `nixosConfigurations.<hostname>` as the first argument to `mkHomeConfiguration` — that's how the home-manager side inherits `pkgs` and `specialArgs` from the paired system. See `flake.nix#nixosConfigurations` and `flake.nix#homeConfigurations` for the concrete record shape.

# Related

* [custom-lib](custom-lib.md) — how `self.lib.*` gets populated.
* [mixin-pattern](mixin-pattern.md) — the modules these constructors compose.
* [decisions/standalone-home-manager](/decisions/standalone-home-manager.md) — why home-manager isn't a NixOS module.
