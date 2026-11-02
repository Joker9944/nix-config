---
type: Host
title: wintermute
description: Lenovo ThinkPad X1 Yoga Gen 4 laptop, x86_64-linux, Swiss keymap, 4K panel.
tags: [host, laptop, hyprland, thinkpad]
generated:
  by: claude-code/claude-opus-5
  at: 2026-11-02T00:00:00Z
---

# Hardware

Lenovo ThinkPad X1 Yoga Gen 4. Internal panel is `eDP-1`. Reference: <https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_4)>.

Host-specific quirks (all in `modules/nixos/hosts/wintermute/default.nix`):

* Fingerprint reader service (`fprintd`) is explicitly disabled.
* Firmware updates via `fwupd` are enabled.
* Regreet window rule pinned to `eDP-1` (vs `DP-2` on HAL9000).
* Blue limine boot branding (vs HAL9000's red).
* Tailscale accepts subnet routes (`useRoutingFeatures = "client"` + `--accept-routes`), to reach the [nyx](nyx-cluster.md) kube-vip from off-LAN.
* Swiss keymap: `services.xserver.xkb.layout = "ch";`
* TLP's battery charge thresholds (75/80 %) are set here, not in the battery mixin: they reach the
  pack through `thinkpad_acpi`. They are the values the firmware was already enforcing.
* Power policy arrives with `mixins.hardware.battery` (the only host enabling it): lid close is
  `suspend-then-hibernate`, with `HibernateOnACPower = false` so the escalation clock starts at
  unplug. Hibernation needs no `boot.resumeDevice` or `resume_offset` despite the swapfile sitting
  on btrfs inside LUKS — systemd writes a `HibernateLocation` EFI variable and resumes from it in
  the systemd initrd. `/sys/power/resume` reading `0:0` is therefore expected, not a fault.
* `eDP-1` is declared (`3840x2160@60.00Hz`, scale 2, the panel's only mode) rather than left to
  Hyprland's inference, because the lid binds in
  `modules/home/users/joker9944/hosts/wintermute/default.nix` derive their restore spec from that
  declaration. They disable the panel on lid close, which logind deliberately ignores while docked;
  `hl.monitor` and a lua function are used because the lua API exposes no `keyword` dispatcher.
* Bluetooth is enabled here and nowhere else (HAL9000 has no radio), as a raw `hardware.bluetooth.enable` line rather than a mixin — see [decisions/gnome-keyring-not-core-os-services](/decisions/gnome-keyring-not-core-os-services.md).

# Host record & mixin selection

Host record: `flake.nix#nixosConfigurations`, selecting `profile = "hyprland-desktop"` — the shared graphical baseline (see [profiles](/architecture/profiles.md)). `modules/nixos/hosts/wintermute/mixins.nix` holds only the deltas: `openssh`, `windowsSupport`, `networking.hosts`, `hardware.battery` — the only host with a battery, which the [yas](/apps/yas.md) mixin reads to enable its battery module — plus `hardware.intelCpu` and `hardware.thermalThrottling` — the latter is enabled nowhere else, so thermald runs only here ([why the mechanism is derived](/architecture/mixin-pattern.md#where-per-host-config-lives)). It differs from [HAL9000](HAL9000.md) — same profile, but no Nvidia / Steam / Docker — solely in those deltas.

Home-manager side: `modules/home/users/joker9944/hosts/wintermute/default.nix` enables the `wayvnc` mixin and holds the monitor declaration and lid binds. The [yas](/apps/yas.md) battery module follows from the same mixin flag, so it is off on every other host without being named here. `ollama` is enabled per-host on [HAL9000](HAL9000.md) rather than in the shared user config, to keep it off this battery.

# Related

* [HAL9000](HAL9000.md) — the desktop counterpart. A shared concern belongs in the common `hyprland-desktop` [profile](/architecture/profiles.md), not copied into both `mixins.nix` files.
* [architecture/entry-points](/architecture/entry-points.md).
