---
type: Host
title: wintermute
description: Lenovo ThinkPad X1 Yoga Gen 4 laptop, x86_64-linux, Swiss keymap, 4K panel.
tags: [host, laptop, hyprland, thinkpad]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-16T00:00:00Z
---

# Hardware

Lenovo ThinkPad X1 Yoga Gen 4. Internal panel is `eDP-1`. Reference: <https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_4)>.

Host-specific quirks (all in `hosts/wintermute/default.nix`):

* Fingerprint reader service (`fprintd`) is currently disabled.
* Firmware updates via `fwupd` are enabled.
* Regreet window rule pinned to `eDP-1` (vs `DP-2` on HAL9000).
* Blue limine boot branding (vs HAL9000's red).
* Swiss keymap: `services.xserver.xkb.layout = "ch";`

# Host record & mixin selection

Host record: `flake.nix#nixosConfigurations`, selecting `profile = "hyprland-desktop"` — the shared graphical baseline (see [profiles](/architecture/profiles.md)). `hosts/wintermute/mixins.nix` holds only the deltas: `openssh` and `windowsSupport`. It differs from [HAL9000](HAL9000.md) — same profile, but no Nvidia / Steam / Docker — solely in those deltas.

Home-manager side: `users/joker9944/hosts/wintermute/default.nix` enables the `wayvnc` mixin and sets `programs.yas.config.battery = true;` — the only host with a battery, so the [yas](/apps/yas.md) battery module is off everywhere else.

# Related

* [HAL9000](HAL9000.md) — the desktop counterpart. A shared concern belongs in the common `hyprland-desktop` [profile](/architecture/profiles.md), not copied into both `mixins.nix` files.
* [architecture/entry-points](/architecture/entry-points.md).
