---
type: Playbook
title: Rebuild the system
description: How to rebuild NixOS and home-manager from this flake, via nh or the underlying tools.
tags: [workflow, build, nixos, home-manager]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-12T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# Trigger

You changed something in this repo and want the running system to reflect it.

# nh

`nh` (`mixins.programs.nh`) is the interactive front-end over both tools below — package diff, `-a` to confirm before activating. The mixin points `NH_FLAKE` at `<projects dir>/nix-config`, so the flakeref can be omitted from any directory; that location is a convention the repo does not enforce.

# NixOS

```bash
nh os switch
# or
nixos-rebuild switch --flake .
```

The current hostname auto-selects the right configuration.

Common variants:

* `nixos-rebuild boot --flake .` — build and activate on next reboot instead of now (safer for kernel/initrd changes).
* `nixos-rebuild build --flake .` — build only, don't activate. Useful for smoke-testing before switching.

# Home-manager

Home-manager runs standalone here (see [decisions/standalone-home-manager](/decisions/standalone-home-manager.md)):

```bash
nh home switch
# or
home-manager switch --flake .#joker9944@HAL9000
```

The configuration key format is `<username>@<hostname>`; `nh` derives it from the current user and hostname.

# Checks and dry runs

* `nix flake check` — runs the full `checks.<system>.*` set: pre-commit hooks (see [formatting-and-cspell](formatting-and-cspell.md)) and lib tests.
* `nix run .#test-lib` — runs just the lib tests (`tests/lib/`).

# Related

* [add-mixin](add-mixin.md) — after adding a mixin, rebuild is what makes it take effect.
* [formatting-and-cspell](formatting-and-cspell.md) — pre-commit runs before every commit.
