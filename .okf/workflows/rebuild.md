---
type: Playbook
title: Rebuild the system
description: How to rebuild NixOS and home-manager from this flake, including the shell completions that make the invocation short.
tags: [workflow, build, nixos, home-manager]
timestamp: 2026-07-17T00:00:00Z
---

# Trigger

You changed something in this repo and want the running system to reflect it.

# NixOS

```bash
nixos-rebuild switch --flake .
```

The current hostname auto-selects the right configuration. The fish shell config (`users/joker9944/config/fish.nix`) provides completions that offer `.` (the current directory) and `github:joker9944/nix-config` as `--flake` candidates.

Common variants:

* `nixos-rebuild boot --flake .` — build and activate on next reboot instead of now (safer for kernel/initrd changes).
* `nixos-rebuild build --flake .` — build only, don't activate. Useful for smoke-testing before switching.

# Home-manager

Home-manager runs standalone here (see [decisions/standalone-home-manager](/decisions/standalone-home-manager.md)):

```bash
home-manager switch --flake .#joker9944@HAL9000
# or
home-manager switch --flake .#joker9944@wintermute
```

The configuration key format is `<username>@<hostname>`. The same fish completions apply.

# Checks and dry runs

* `nix flake check` — runs the full `checks.<system>.*` set: pre-commit hooks (see [formatting-and-cspell](formatting-and-cspell.md)) and lib tests.
* `nix run .#test-lib` — runs just the lib tests (`tests/lib/`).

# Related

* [add-mixin](add-mixin.md) — after adding a mixin, rebuild is what makes it take effect.
* [formatting-and-cspell](formatting-and-cspell.md) — pre-commit runs before every commit.
