---
type: Playbook
title: Bootstrap the nyx cluster
description: Order and per-host facts for rolling out tars, case, kipp and mother onto k3s, migrating off Talos + TrueNAS.
tags: [workflow, install, k3s, cluster, nyx]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-07T00:00:00Z
---

# Trigger

Standing up the four [nyx-cluster](/hosts/nyx-cluster.md) machines. Each machine is installed with [install-nixos](install-nixos.md); this playbook only adds the ordering and the per-host facts.

# 1. Prepare all four host keys at once

Do step 3 of [install-nixos](install-nixos.md) for all four hosts before installing any of them, into `seed/<name>/`. All four age recipients go onto the dedicated `secrets/k3s\.yaml$` rule in `.sops.yaml`, then a single `sops updatekeys` and one commit — the alternative is four re-encryptions of the same file.

Keeping them on the dedicated rule rather than the general one is what confines the cluster to the k3s token; see [secrets](secrets.md).

# 2. Install in order

| Order | Host | Why here |
|---|---|---|
| 1 | tars | `clusterInit`; deploys the kube-vip manifest that claims 192.168.0.20 |
| 2 | case | joins the VIP as a server |
| 3 | kipp | joins the VIP as a server |
| 4 | mother | agent; the only host importing `chronos` |

`case`, `kipp` and `mother` all register against `serverAddr = https://192.168.0.20:6443`, so nothing after `tars` can join until the VIP answers. Confirm it does before continuing:

```bash
curl -k https://192.168.0.20:6443/livez
```

When it does not, the joiners fail with `dial tcp 192.168.0.20:6443: connect: no route to host` and
restart forever; `ip -4 addr` on `tars` showing no `192.168.0.20` means kube-vip never claimed it.
Read the env back out of the deployed manifest (the symlink under
`/var/lib/rancher/k3s/server/manifests/`) rather than the repo — a stale generation looks identical
from the source side. Removing a field from the DaemonSet is the case to double-check: confirm it is
gone from the live object, and delete the DaemonSet to force a clean recreate if the re-apply kept it.

Once it answers, a joiner failing on `x509: certificate is valid for … not <vip>` means the serving cert predates the `--tls-san` flag. k3s does not reissue when the SAN list changes, so adding the flag and rebuilding is not enough — drop the cert and let dynamiclistener rebuild it:

```bash
kubectl -n kube-system delete secret k3s-serving
systemctl restart k3s
```

# 3. Facts to resolve on the machine

Each is a `TODO` in-tree today:

| Fact | Where | How |
|---|---|---|
| OS SSD device name | `hosts/mother/disks.nix` | `lsblk` |
| `hostId` | `hosts/mother/default.nix` | `head -c4 /dev/urandom \| od -A none -t x4` |
| NFS export paths | `hosts/mother/default.nix` | the `/export` entry is a placeholder |
| `vonarx.online/*` labels | every host's `nodeLabel` | port from the Talos node config |

# 4. mother — before first boot

`chronos` is a pre-existing 8×HDD pool, imported through `boot.zfs.extraPools` and never disko-managed. Import it read-only from the installer and check every encrypted dataset:

```bash
zpool import -o readonly=on chronos
zfs list -o name,keylocation,keystatus -t filesystem,volume chronos
```

Every `keylocation` must be a `file://…` path. A dataset left at `prompt` blocks the boot-time import service on `systemd-ask-password`, and `boot.zfs.passwordTimeout` defaults to `0` — it waits forever, on a headless machine. Export again (`zpool export chronos`) before installing.

# 5. Cluster checks

```bash
ssh tars kubectl get nodes -o wide          # four Ready nodes
ssh <each> systemctl status sops-install-secrets
ssh <each> systemctl status k3s
```

# Related

* [install-nixos](install-nixos.md) — the per-machine procedure.
* [hosts/nyx-cluster](/hosts/nyx-cluster.md) — what these machines are and how they're configured.
* [secrets](secrets.md) — the k3s token and its recipients.
