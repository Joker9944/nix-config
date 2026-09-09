---
type: Host
title: nyx cluster
description: Four headless x86_64-linux machines running k3s — tars/case/kipp as servers, mother as a NAS agent — migrated off Talos + TrueNAS.
tags: [host, server, k3s, zfs, longhorn]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-09T00:00:00Z
sources:
  - id: longhorn-2166
    resource: https://github.com/longhorn/longhorn/issues/2166
    title: "longhorn#2166 — NixOS support: nsenter cannot find host binaries"
---

# Machines

| Host | Address | k3s role | Deltas |
|---|---|---|---|
| tars | 192.168.0.21/23 | server, `clusterInit` | deploys the kube-vip manifest |
| case | 192.168.0.22/23 | server | — |
| kipp | 192.168.0.23/23 | server | — |
| mother | 192.168.0.24/23 | agent | `zfs` + `nfs` mixins, `hostId`, `chronos` pool |

All four select `profile = "server"` (see [profiles](/architecture/profiles.md)); their `mixins.nix` files hold only the role deltas. Static addressing is per host under `systemd.network.networks."10-lan"`, since the profile only turns systemd-networkd on. `tars` names its exact interface rather than globbing `en*`: the glob also matches its unpopulated second onboard NIC, which then inherits `RequiredForOnline` and hangs `systemd-networkd-wait-online` for its full timeout before failing — and would take a duplicate copy of the static address the day anyone cables it. The others have no second NIC and keep the glob.

# The kube-vip endpoint

`tars` bootstraps the cluster and deploys kube-vip as an auto-deploy manifest (`services.k3s.manifests.kube-vip.content`, a list of Kubernetes objects). It claims **192.168.0.20** in ARP mode — the address the Talos cluster used — so `case`/`kipp`/`mother` register against a `serverAddr` that survives losing `tars`.

The kube-vip image tag is a literal at the top of `modules/nixos/hosts/tars/default.nix`. `vip_interface` is deliberately left unset: the DaemonSet is one object scheduled onto every control-plane node, and the wired interface is not named the same on each (`enp2s0` on tars and case, `eno1` on kipp), so no single literal is correct. kube-vip then binds the default-route interface, which on each node is the one holding the VIP's own subnet.

Each server also passes `--tls-san=<vip>` through `services.k3s.extraFlags`. This is a guard, not the join mechanism: dynamiclistener already learns SANs from incoming requests, so a cert reissued while joiners are connecting picks the VIP up on its own. The flag is what makes it declarative — a cert regenerated before anything asks for the VIP (a cold bootstrap where the first server comes up alone) would otherwise omit it and lock the joiners out. The flag is per host, not in the k3s mixin — it is environment-specific, and `k3s agent` does not define it, so `mother` must not receive it.

`services.k3s.disable` is server-only for the same reason — `k3s agent` rejects `--disable` outright — but its value is identical on every server, so the mixin keeps it and gates it on `role == "server"` instead of repeating the list in three hosts. Server-only k3s settings belong in the mixin behind that gate when they are uniform, and on the host when the value varies.

# GPU on mother

A GTX 1660 SUPER, the only GPU in the cluster. `mother` takes the `nvidia` mixin without `nvidiaCuda`: Jellyfin wants NVENC/NVDEC, which the driver provides, so `cudaSupport` would rebuild the package set for nothing.

`hardware.nvidia-container-toolkit.enable` runs a boot oneshot writing a CDI spec to `/run/cdi/nvidia-container-toolkit.json`, declaring `nvidia.com/gpu=0` and `=all`. containerd 2.2, which k3s 1.35 bundles, enables CDI by default over `/var/run/cdi`, so a `cdi.k8s.io/<key>: nvidia.com/gpu=0` pod annotation claims the device with nothing else in place.

For a runtime handler instead: k3s locates runtimes with `exec.LookPath`, so the `k3s` mixin puts `pkgs.nvidia-container-toolkit.tools` on the unit's `PATH` wherever the toolkit is enabled, and k3s emits `nvidia` and `nvidia-cdi` handlers into its generated containerd config. Use `nvidia-cdi` — plain `nvidia` runs in auto mode and falls back to legacy libnvidia-container, which has no FHS driver tree here. k3s creates no `RuntimeClass` object, so that resource is still yours to apply. Do not reach for `services.k3s.containerdConfigTemplate`: nixpkgs writes it to `config.toml.tmpl`, which k3s reads as the v2 generation and downgrades the whole containerd config off v3. The v3 drop-in dir is `/var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.d/`.

# Remote access

All three servers advertise `192.168.0.20/32` into the tailnet — `services.tailscale.useRoutingFeatures = "server"` for the forwarding sysctl, `extraSetFlags = [ "--advertise-routes=…" ]` for the `tailscaled-set.service` oneshot. Advertising from every server rather than one lets Tailscale's primary-router election fail the tailnet route over the same way kube-vip fails the VIP over at L2.

Two halves are outside nix. The route must be **approved** in the Tailscale admin console (or by an ACL `autoApprovers` entry) before any client sees it; and `tailscale set` writes persistent prefs, so deleting the nix lines only removes the unit — unadvertising needs an explicit `tailscale set --advertise-routes=` on the node.

Linux clients ignore subnet routes unless told otherwise, so [wintermute](wintermute.md) carries the matching `useRoutingFeatures = "client"` + `--accept-routes`. Phones and macOS accept by default.

# Storage

Disks come from the `server-longhorn-v1` [disko template](/architecture/custom-lib.md): no LUKS, an ESP, an **optional** dedicated plain-xfs `/var/lib/longhorn`, then btrfs `root`/`home`/`nix`. It is `size`-based rather than `end`-based like the desktop templates, and the 100 % btrfs partition auto-sorts last under disko's priority 9001. `mkDiskoLayout` carries `longhorn = null` in its size defaults, so the partition disappears once a dedicated Longhorn disc lands and the mount moves to a sibling disk block.

`mother` additionally imports the pre-existing `chronos` pool through `boot.zfs.extraPools`: raidz2 over 8×SATA HDD plus a log vdev on an Intel Optane (`nvme1n1`). That pool is **never** disko-managed, and because the machine has two NVMe devices its `disks.nix` addresses the OS SSD by-id so a wipe cannot reach the Optane. [workflows/diagnose-disk-faults](/workflows/diagnose-disk-faults.md) covers what to do when a member faults.

The `zfs` mixin alerts on that pool through ZED's own Gotify backend — no mail bridge — with `ZED_NOTIFY_VERBOSE` on, since a clean scrub is otherwise silent and silence cannot be told apart from a dead zed. The app token is a `$(cat …)` command substitution over a sops secret rather than a plain `zed.settings` value: zed.rc is sourced by each zedlet, so the substitution runs there, while the value itself would land in the world-readable `/etc/zfs/zed.d/zed.rc`. `EnvironmentFile` on `zfs-zed.service` is not an alternative — zed builds its children's environment from scratch and preserves only `TZ`.

Longhorn's node prerequisites sit in the `k3s` mixin so every node gets them: `services.openiscsi`, and `boot.supportedFilesystems.nfs` for the `mount.nfs` that RWX volumes and pod-level NFS shares need.

Installing them is not enough. longhorn-manager reaches host tools with `nsenter <host ns> <tool>`, which keeps the *container's* PATH — and no directory on that PATH exists here — while its RWX path hardcodes `/usr/bin` outright[^longhorn-2166]. The mixin therefore symlinks `iscsiadm`, `mount`, `umount` and the NFS mount helpers into `/usr/bin`, the one FHS directory NixOS already populates (`env`), which satisfies both. Without them the manager crashloops on `exit status 127` naming a tool that is in fact installed — and a PATH-only workaround, such as giving `iscsid` a private mount namespace with `BindPaths`, clears that crash while leaving RWX broken.

`mother` exports `/chronos/media-data` over **NFSv4 only** — the `nfs` mixin opens 2049 and nothing else, so rpcbind's 111 is closed and `showmount` reports nothing on a server that is working fine. Clients must not fall back to v3.

# Rollout state

All four are installed and running k3s; TrueNAS is gone. [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md) keeps the order and per-host facts for a rebuild from scratch.

# Related

* [architecture/profiles](/architecture/profiles.md) — why these are one profile plus mixins rather than four roles.
* [decisions/host-profiles](/decisions/host-profiles.md) — the multi-role case that keeps `k3s`/`zfs`/`nfs` as mixins.
* [architecture/entry-points](/architecture/entry-points.md) — how the `flake.nix` records become `nixosConfigurations`. These are headless, so they have no `homeConfigurations`.
