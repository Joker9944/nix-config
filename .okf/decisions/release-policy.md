---
type: Decision
title: Track stable nixos, upgrade in lockstep
description: nixpkgs and home-manager are pinned to matching stable release branches and upgraded together at each nixos release. Hyprland from upstream and a per-package `pkgs-unstable` are the two deliberate escape hatches.
tags: [decision, releases, flake]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-21T00:00:00Z
verified:
  - by: claude-code/claude-opus-5
    at: 2026-08-16T00:00:00Z
---

# The rule

* `nixpkgs` follows the current *stable* nixos channel (`nixos-N.NN`), never `nixos-unstable`.
* `home-manager` is pinned to the matching `release-N.NN` — always the same major/minor as nixpkgs.
* Both are bumped together with each new nixos release (roughly May and November).
* Two escape hatches exist. `hyprland` is taken from upstream `github:hyprwm/Hyprland` at a pinned tag rather than the nixpkgs package, and bumped independently of the nixos release train. Per-package, `custom.pkgs.pkgs-unstable` (`lib/configuration/mkNixosConfiguration.nix`) exposes `nixos-unstable` as `pkgs-unstable`, which around 25 files pull individual packages from.

Current pins live in `flake.nix#inputs`; concrete revisions are in `flake.lock`.

# Why

* **Stable over unstable.** nixos stable branches receive vetted updates and rarely land breaking changes mid-cycle. That matters for a personal daily-driver where a broken build blocks a workday.
* **Lockstep home-manager.** Each home-manager release branch targets a specific nixpkgs release. Mixing versions (say, `release-26.05` with `nixos-26.11`) works only by coincidence and produces evaluation errors as modules drift apart.
* **Hyprland from upstream.** Hyprland moves fast enough that the nixos-packaged version lags meaningful features and fixes. Since hyprland is the daily-driver DE (see [hosts/HAL9000](/hosts/HAL9000.md), [hosts/wintermute](/hosts/wintermute.md)), tracking upstream is worth the maintenance churn.

# Trade-off accepted

* **Delayed access to new packages.** Anything landing on unstable takes about six months to reach here.
* **Semi-annual coordinated upgrade.** nixpkgs, home-manager, and any user-facing option renames all land at once, not on a smooth continuous curve. The `home-manager-options` skill (`.claude/skills/home-manager-options/SKILL.md`) exists in part to catch the option-rename churn that comes with each release-N.NN bump.
* **Anything on an escape hatch can break independently.** An upstream regression or option rename requires an ad-hoc fix, and a `pkgs-unstable` package can change its config schema mid-cycle with no upgrade moment to catch it — yazi 26.8 moved opener placeholders from `$1` to `%s1`, which silently handed every opener an empty argument.

# Related
