---
type: Architecture Pattern
title: Entry points — mkNixosConfiguration, mkHomeConfiguration & mkNixOnDroidConfiguration
description: The constructors called from flake.nix that assemble every host system, every home-manager configuration and the nix-on-droid phone.
tags: [architecture, flake, entry-point]
generated:
  by: claude-code/claude-opus-4-8
  at: 2026-10-20T00:00:00Z
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

# `mkNixOnDroidConfiguration`

Defined in `lib/configuration/mkNixOnDroidConfiguration.nix`. Builds an Android device from
`flake.nixOnDroidModules."hosts-<hostname>"` (`modules/nix-on-droid/hosts/<hostname>/`), with
home-manager **integrated** (`home-manager.config`), since nix-on-droid has no standalone form. There
is no paired NixOS config, so it imports nixpkgs itself with the flake's overlays, and the shared
home tree — `homeModules.mixins`, `theme`, every `public-*` — arrives via `home-manager.sharedModules`.
`users-<username>` is not loaded: it is desktop-shaped and reads `osConfig`; the host's own
`home.nix` enables mixins instead.

nix-on-droid evaluates home-manager as a bare submodule, so the constructor restores two special
args standalone home-manager sets: `_class = "homeManager"` (else `mkClassModule` drops the theme's
nix-schemes half) and `modulesPath` (else a string `disabledModules`, as in the vicinae backport,
matches nothing and the option is declared twice). `osConfig` is `null` there, which home mixins
must survive even while disabled — a submodule-typed definition read from `osConfig` is forced
regardless of `mkIf` (`modules/home/mixins/services/maintenance.nix`).

The activation package is impure: nix-on-droid pins `proot-termux` with `builtins.storePath`, so it
evaluates only with `--impure` (which `nix-on-droid switch` passes) and with that path present —
hence it is kept out of `checks.evalConfigurations`.

# How they're called

`flake.nix` pipes a list of host records through `lib.map` and `lib.listToAttrs`. `nixosConfigurations` is keyed by `hostname`. `homeConfigurations` is keyed by `<username>@<hostname>` and passes the already-built `nixosConfigurations.<hostname>` as the first argument to `mkHomeConfiguration` — that's how the home-manager side inherits `pkgs` and `osConfig` from the paired system. `nixOnDroidConfigurations` is keyed by `hostname` too; on the device, `nix-on-droid switch --flake <path>#<hostname>`. See `flake.nix#nixosConfigurations` and `flake.nix#homeConfigurations` for the concrete record shape.

# Related

* [custom-lib](custom-lib.md) — how `self.lib.*` gets populated.
* [mixin-pattern](mixin-pattern.md) — the modules these constructors compose.
* [profiles](profiles.md) — the role module `mkNixosConfiguration` pulls in from the `profile` string.
* [decisions/standalone-home-manager](/decisions/standalone-home-manager.md) — why home-manager isn't a NixOS module.
