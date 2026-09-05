---
type: Host
title: nyx cluster
description: Four headless x86_64-linux machines running k3s — tars/case/kipp as servers, mother as a NAS agent — migrated off Talos + TrueNAS.
tags: [host, server, k3s, zfs, longhorn]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-05T00:00:00Z
---

# Machines

| Host | Address | k3s role | Deltas |
|---|---|---|---|
| tars | 192.168.0.21/23 | server, `clusterInit` | deploys the kube-vip manifest |
| case | 192.168.0.22/23 | server | — |
| kipp | 192.168.0.23/23 | server | — |
| mother | 192.168.0.24/23 | agent | `zfs` + `nfs` mixins, `hostId`, `chronos` pool |

All four select `profile = "server"` (see [profiles](/architecture/profiles.md)); their `mixins.nix` files hold only the role deltas. Static addressing is per host under `systemd.network.networks."10-lan"`, since the profile only turns systemd-networkd on.

# The kube-vip endpoint

`tars` bootstraps the cluster and deploys kube-vip as an auto-deploy manifest (`services.k3s.manifests.kube-vip.content`, a list of Kubernetes objects). It claims **192.168.0.20** in ARP mode — the address the Talos cluster used — so `case`/`kipp`/`mother` register against a `serverAddr` that survives losing `tars`.

`vip_interface` and the kube-vip image tag are literals at the top of `modules/nixos/hosts/tars/default.nix`; both are marked `TODO` pending the real interface name from the machine.

# Storage

Disks come from the `server-longhorn-v1` [disko template](/architecture/custom-lib.md): no LUKS, an ESP, an **optional** dedicated plain-xfs `/var/lib/longhorn`, then btrfs `root`/`home`/`nix`. It is `size`-based rather than `end`-based like the desktop templates, and the 100 % btrfs partition auto-sorts last under disko's priority 9001. `mkDiskoLayout` carries `longhorn = null` in its size defaults, so the partition disappears once a dedicated Longhorn disc lands and the mount moves to a sibling disk block.

`mother` additionally imports the pre-existing `chronos` pool (8×SATA HDD) through `boot.zfs.extraPools`. That pool is **never** disko-managed.

# Rollout state

None of the four is installed. `hardware-configuration.nix` exists only for `tars`, as a placeholder of typical-NUC guesses so the config evaluates before first boot, and no host is yet a recipient of the k3s token.

[workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md) carries the rollout order and the table of `TODO` facts each machine has to supply.

# Related

* [architecture/profiles](/architecture/profiles.md) — why these are one profile plus mixins rather than four roles.
* [decisions/host-profiles](/decisions/host-profiles.md) — the multi-role case that keeps `k3s`/`zfs`/`nfs` as mixins.
* [architecture/entry-points](/architecture/entry-points.md) — how the `flake.nix` records become `nixosConfigurations`. These are headless, so they have no `homeConfigurations`.
