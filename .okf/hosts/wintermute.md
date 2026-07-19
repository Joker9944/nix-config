---
type: Host
title: wintermute
description: Lenovo ThinkPad X1 Yoga Gen 4 laptop, x86_64-linux, Swiss keymap, 4K panel.
tags: [host, laptop, hyprland, thinkpad]
timestamp: 2026-07-17T00:00:00Z
---

# Hardware

Lenovo ThinkPad X1 Yoga Gen 4. Internal panel is `eDP-1`. Reference: <https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_4)>.

Host-specific quirks (all in `hosts/wintermute/default.nix`):

* Fingerprint reader service (`fprintd`) is currently disabled.
* Firmware updates via `fwupd` are enabled.
* Regreet window rule pinned to `eDP-1` (vs `DP-2` on HAL9000).
* Blue limine boot branding (vs HAL9000's red).
* Swiss keymap: `mixins.keymap.type = "ch";`.

# Host record & mixin selection

Host record: `flake.nix#nixosConfigurations`. Enabled NixOS mixins: `hosts/wintermute/mixins.nix`. The mixin set overlaps with [HAL9000](HAL9000.md) but omits Nvidia / Steam / Docker and adds `openssh`.

# Related

* [HAL9000](HAL9000.md) — the desktop counterpart. Compare `mixins.nix` files when the two hosts should stay in sync on a shared concern.
* [architecture/entry-points](/architecture/entry-points.md).
