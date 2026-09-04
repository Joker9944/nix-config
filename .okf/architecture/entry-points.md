---
type: Architecture Pattern
title: Entry points — mkNixosConfiguration & mkHomeConfiguration
description: The two constructors called from flake.nix that assemble every host system and every home-manager configuration.
tags: [architecture, flake, entry-point]
generated:
  by: claude-code/claude-opus-4-8
  at: 2026-09-04T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# `mkNixosConfiguration`

Defined in `lib/configuration/mkNixosConfiguration.nix`. Assembles a `nixosSystem` by selecting keys of `flake.nixosModules` (populated by `mkModules` — see [auto-discovery](auto-discovery.md#the-flake-level-collector-mkmodules)):

1. `nixosModules.mixins` — the reusable NixOS mixin tree, `modules/nixos/mixins/`.
2. `nixosModules."profiles-<profile>"` — the host's role, when the record sets a `profile` string (optional). See [profiles](profiles.md).
3. `nixosModules."hosts-<hostname>"` — the per-host directory `modules/nixos/hosts/<hostname>/`, whose `default.nix` auto-loads its siblings (`mixins.nix`, `disks.nix`, `hardware-configuration.nix`, …) via `mkDefaultModule`.
4. `nixosModules."users-<username>"` for each username in the host record — user-owned system-level tweaks, `modules/nixos/users/<username>/`. The module keeps a universal identity (account, ssh keys, `wheel`/`keys` groups) unconditional and gates its desktop-coupled extras — capability group memberships per owning mixin (`docker`/`gamemode`/`networkmanager`), the unfree-package allowlist and the `audiomenu` overlay on `mixins.programs.home-manager.enable` — so it imports cleanly on a graphical-free server.
5. Every `public-*` key, `nixosModules.theme`, and inline wiring: the flake's overlays, `nixpkgs.hostPlatform` and the `custom.pkgs.pkgs-unstable` binding.

Neither constructor sets `specialArgs`. Modules receive `flake`, `inputs`, `libUtil` and `libMath` as
static `importApply` arguments bound in `flake.nix#moduleArgs` — see [custom-lib](custom-lib.md).
Static args resolve in `imports` position, which `mkDefaultModule` and the mixin aggregators depend
on; `_module.args` would not.

# `mkHomeConfiguration`

Defined in `lib/configuration/mkHomeConfiguration.nix`. Builds a **standalone** home-manager configuration — home-manager is not a NixOS module here (see [decisions/standalone-home-manager](/decisions/standalone-home-manager.md)). Inherits `pkgs` from the paired NixOS configuration, so both trees stay in lockstep.

Sources, again by `flake.homeModules` key:

1. `homeModules.mixins` — the reusable home-manager mixin tree, `modules/home/mixins/`.
2. `homeModules."users-<username>"` — user-owned modules, `modules/home/users/<username>/` (`default.nix`, `config/`, `hosts/<hostname>/`).
3. Every `public-*` key and `homeModules.theme`.

The constructor takes no hostname: `osConfig` is the sole `extraSpecialArg` — a lazy reference to the
paired NixOS config, and the one value a static arg cannot carry, since
`modules/home/users/joker9944/default.nix` reads it in `imports` position to pick its per-host module
(`./hosts/<osConfig.networking.hostName>`, imported only when that directory exists). Also used, for
example, to inherit `osConfig.mixins.desktopEnvironment` and by
`modules/home/users/joker9944/hosts/HAL9000/default.nix` to read `osConfig.programs.steam.package`.

# How they're called

`flake.nix` pipes a list of host records through `lib.map` and `lib.listToAttrs`. `nixosConfigurations` is keyed by `hostname`. `homeConfigurations` is keyed by `<username>@<hostname>` and passes the already-built `nixosConfigurations.<hostname>` as the first argument to `mkHomeConfiguration` — that's how the home-manager side inherits `pkgs` and `osConfig` from the paired system. See `flake.nix#nixosConfigurations` and `flake.nix#homeConfigurations` for the concrete record shape.

# Related

* [custom-lib](custom-lib.md) — how `self.lib.*` gets populated.
* [mixin-pattern](mixin-pattern.md) — the modules these constructors compose.
* [profiles](profiles.md) — the role module `mkNixosConfiguration` pulls in from the `profile` string.
* [decisions/standalone-home-manager](/decisions/standalone-home-manager.md) — why home-manager isn't a NixOS module.
