---
type: Playbook
title: Renumber a nyx cluster node
description: Move cluster nodes to new LAN addresses without partitioning the cluster — widen the firewall allow-set first, then roll node by node, updating each etcd member's peer URL before it moves.
tags: [workflow, networking, k3s, etcd, cluster, nyx]
generated:
  by: claude-code/claude-opus-5
  at: 2026-11-03T00:00:00Z
sources:
  - id: k3s-5787
    resource: https://github.com/k3s-io/k3s/issues/5787
    title: "k3s#5787 — changing a node IP is unsupported; etcd members are not re-addressed"
  - id: etcd-reconfig
    resource: https://etcd.io/docs/v3.3/op-guide/runtime-configuration/
    title: "etcd — runtime reconfiguration: update a member's peer URLs, then restart it"
  - id: k3s-etcd-snapshot
    resource: https://docs.k3s.io/cli/etcd-snapshot
    title: "k3s CLI — etcd-snapshot, --cluster-reset, --cluster-reset-restore-path"
---

# Trigger

A [nyx cluster](/hosts/nyx-cluster.md) node's LAN address changes. Standing up a cluster from
nothing is [nyx-bootstrap](nyx-bootstrap.md) instead.

# Why this is not just a rebuild

Three things break, independently of each other.

**The firewall allow-set is cluster-wide data.** Each node admits only the addresses in
`lib/network/nyxNodes.nix` as of the generation it is running, so a renumbered node and an
un-renumbered one reject each other in both directions — etcd and kubelet,
and flannel's VXLAN (`udp 8472`) with them. The pod network partitions too, which is how a LAN
renumber reaches Longhorn.

**etcd peer URLs are persisted at the old addresses.** k3s does not support changing a node IP and
will not re-address etcd members for you[^k3s-5787]; raft dials peers at their stored URLs, so a
renumber that vacates them cannot re-form the cluster in *any* node order.

**An agent follows the VIP, and `serverAddr` is not widenable.** `mother` is an agent: it reaches
the apiserver through `serverAddr` plus a persisted fallback list of server addresses in
`/var/lib/rancher/k3s/agent/etc/k3s-agent-load-balancer.json`. When the VIP moves, every address in
both is stale until `mother` itself is rebuilt — and there is no equivalent of the allow-set trick,
because an address is dialled rather than admitted.

The first is avoidable, and avoiding it is what keeps this to rolling single-node maintenance rather
than a cluster-wide outage: admit both the current and the future address set for the duration. The
second is not avoidable, but once both sets are admitted the supported fix is reachable — update a
member's peer URL while quorum is healthy, then move the node into the address just
declared[^etcd-reconfig]. The third sets the node order: `mother` goes second, straight after the
node that moves the VIP.

One further constraint: `--kube-proxy-arg=metrics-bind-address` is `nyxNodes.${hostName}`, so a
node's own entry must match the address it actually holds at every step. The attrset cannot be
flipped wholesale up front.

# 0. Before anything

Confirm the new gateway answers, from a node, while the old routing still works:

```bash
ssh tars ping -c3 192.168.0.254
```

If it does not, stop. The first `nixos-rebuild boot` changes address, gateway and resolver in one
shot, so a dead gateway means a node with no default route — which also takes out tailscaled's path
to the coordination server, leaving console or IPMI as the only way back in, including for
selecting the previous generation in the bootloader.

Snapshot etcd and copy it off-cluster — `k3s etcd-snapshot save` on tars.

`etcdctl` is **not installed** on these nodes — k3s ships `kubectl`, `crictl` and `ctr` and nothing
else — and the embedded etcd authenticates clients by certificate. Build the invocation once on a
server and reuse it:

```bash
nix shell nixpkgs#etcd
etcd=( sudo "$(command -v etcdctl)"
  --endpoints=https://127.0.0.1:2379
  --cacert=/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt
  --cert=/var/lib/rancher/k3s/server/tls/etcd/client.crt
  --key=/var/lib/rancher/k3s/server/tls/etcd/client.key )
"${etcd[@]}" member list   # note each member's id against its current peer URL
```

Members are named `<hostname>-<hash>`, so the hex id to pass to `member update` is the one on the
row whose name starts with that node. Each row carries a **client** URL as well as a peer URL, both
at the node's address; `member update` takes only `--peer-urls`, which is correct — the client URL
is what the member advertises for itself at startup, so it follows the renumber on its own. A row
still showing the old client URL between the update and the reboot is expected, not a missed step.

`sudo` and the absolute path are both load-bearing: the keys are root-only, and `sudo` resets
`PATH` — so a bare `sudo etcdctl` cannot find the `nix shell` binary, and `ETCDCTL_*` exported into
the shell does not survive into it either. Without the certs the dial fails as `error reading server
preface: EOF`, which reads like an unreachable endpoint rather than a missing client cert.

# 1. Widen the allow-set

Add one `<host>-pending` entry per node to `nyxNodes.nix` holding its *future* address, leaving the
canonical entries and every host's `default.nix` alone:

```nix
tars = "192.168.0.21";
# …
tars-pending = "192.168.1.21";
```

Both rule sites — the `mkAllowFrom` calls in `modules/nixos/mixins/services/k3s/default.nix` and
`modules/nixos/hosts/mother/nfs.nix` — build from `lib.attrValues nyxNodes`, so the extra keys widen
the firewall and mother's NFS export ACL together. Nothing reads them by name: `nodeAddress` looks
up `hostName`, so the keys are inert beyond the lists.

`nixos-rebuild switch` all four. No reboot and no address change — but **not** nothing: on `mother`
the widened export ACL restarts `nfs-server.service`, because nixpkgs puts the rendered exports file
in its `restartTriggers`. Every pod holding `/chronos/media-data` blocks through the NFSv4 grace
period. The final narrowing does it a second time; there is no way to change the ACL without it, so
pick the hour accordingly.

Then confirm the rules are live on the nodes, not merely in the source tree — a stale generation
looks identical from the source side:

```bash
ssh <each> iptables -S nixos-fw | grep -o '192\.168\.[0-9.]*' | sort -u   # all eight
```

# Drains do not need to complete

Expect the drain to stall on Longhorn's `instance-manager` — not a DaemonSet pod, so
`--ignore-daemonsets` does not exempt it, and the default `node-drain-policy =
block-if-contains-last-replica` holds its PDB while an attached volume's last healthy replica lives
here. On `longhorn-local-strict` volumes that is permanent by design: `dataLocality: strict-local`
pins the replica to wherever the pod runs, so there is no replica to move.

Let it stall. **The cordon is the requirement; a completed drain is not.** Evicting
`instance-manager` buys nothing when the node is rebooting anyway — it holds the engine and replica
processes, and they go down with it. A completed drain only matters when volumes must stay
*available* throughout, which a reboot rules out. Check what is left and go:

```bash
kubectl get pods -A --field-selector spec.nodeName=<node> \
  -o custom-columns='NS:.metadata.namespace,POD:.metadata.name,OWNER:.metadata.ownerReferences[0].kind'
```

Longhorn's own identity is the node *name* and its replica traffic is on the pod network, so a
renumber is an ordinary reboot to it: on-disk replicas survive and are reused on return within
`replica-replenishment-wait-interval` (600s by default) rather than copied afresh. Single-replica
volumes block until the node is back and recover; `node-down-pod-deletion-policy` defaults to
`do-nothing`, so nothing thrashes trying to reschedule them meanwhile.

What *would* cause loss: removing the Longhorn node or the k8s Node object, `--force`,
`--disable-eviction`, or deleting the PDB. Each marks the node's replicas failed — a pointless
cross-LAN rebuild for a 3-replica volume, and data loss for a single-replica one, which has no other
copy. Node removal is for a node that is not coming back; this one returns in minutes.

# 2. Move tars

tars first because it owns the kube-vip manifest, so the VIP moves as soon as its generation lands.
Expect a brief apiserver blip while the DaemonSet rolls and the VIP is momentarily unclaimed.

```bash
kubectl cordon tars
kubectl drain tars --ignore-daemonsets --delete-emptydir-data
"${etcd[@]}" member update <id> --peer-urls=https://192.168.1.21:2380
```

The member drops out of raft the moment its peer URL names an address it does not hold: peers now
dial an address nothing listens on yet, while it still listens on the old one. The other two keep
quorum, but this node's *local* apiserver is now backed by an etcd outside quorum — so if kube-vip
holds the VIP here, `kubectl` through it fails. Point `kubectl` at another server until the reboot,
and do not read the flakiness as the renumber going wrong.

Now renumber, flipping tars's `default.nix` and its canonical `nyxNodes` entry together and dropping
its `-pending` key:

```bash
nixos-rebuild boot --flake .#tars --target-host 192.168.0.21 --build-host 192.168.0.21 \
  --sudo --ask-sudo-password
# then reboot
```

`boot` and a reboot rather than `switch`: the activation that renumbers the node would kill the LAN
SSH session carrying it, and a cold boot sidesteps whether systemd-networkd drops the vacated
address cleanly under a live k3s.

Wait for `"${etcd[@]}" endpoint health`, a `Ready` node at its new `InternalIP`, both of its URLs
in `member list` on the new address, and the VIP answering, then `kubectl uncordon tars` — before
starting the next node, not after. Longhorn disables its own scheduling on a cordoned node, so
tars's replicas cannot return to healthy while it stays cordoned, and taking the next node down
meanwhile leaves two usable nodes for replica placement.

If etcd did not rejoin, leave it cordoned and take the retreat below rather than landing workloads
on a node that may need a reset.

Prove the peer-URL update holds here, on this one node, before trusting it for case and kipp. k3s
manages etcd membership itself and upstream documents only that it will not re-address members for
you, not what it does when you do it by hand — in practice it left the updated peer URL alone and
the member rejoined on reboot, across all three servers. Still worth confirming per node: if the
member list reverts or the member is dropped, take the retreat below instead of pressing on.

# 3. Move mother, straight away

`mother` has been cut off from the apiserver since the VIP moved in step 2, so it goes next and
promptly — a drawn-out gap here means a `NotReady` storage node, evicted pods and degraded Longhorn
replicas, which is the outcome this playbook exists to avoid.

Same cordon, drain and renumber, with no etcd step — it is an agent. If the kubelet returns
advertising its old `InternalIP`, `kubectl delete node mother` and restart k3s; the label and taint
come back with the re-registration, which is the only time they apply at all (see
[nyx-bootstrap](nyx-bootstrap.md#3-node-labels-and-taints)).

# 4. Move case, then kipp

Exactly as step 2, one at a time, each with its own `member update` before the reboot. Neither needs
`serverAddr` to resolve while it is already joined — their apiserver is local — so they can wait.
Do not start the second until the first is green.

# 5. Cert and routes

The VIP moved, so the serving cert's SANs are stale — reissue it exactly as
[nyx-bootstrap](nyx-bootstrap.md) describes, by deleting `kube-system/k3s-serving` and restarting.

Then approve the new subnet routes in the Tailscale admin console. `tailscale set` replaced the
advertised set wholesale and approval does not carry across the change, so the old routes are gone
and the new ones admit nothing until approved.

# 6. Narrow the allow-set

With every `-pending` key dropped as its node moved, `nyxNodes.nix` is back to four canonical
entries at the new addresses — but the source being clean does not mean the nodes are. Each node was
built while the *other* nodes' pending keys still existed, so every generation except the last one
built still admits vacated addresses. A final pass over all four is the only thing that narrows
them, and mother's second `nfs-server` restart lands here:

```bash
ssh <each> iptables -S nixos-fw | grep -o '192\.168\.0\.[0-9]*' | sort -u   # empty when done
```

No host outside the cluster carries a cluster address any more. `wintermute` and `HAL9000` used to
pin the tailnet-only subdomains to the ingress through the `hosts` mixin; those are MagicDNS names
from the Tailscale operator now, so renumbering nodes does not touch them.

# When the rolling path fails

If the peer-URL update does not stick, retreat rather than fight it. Stop the workloads so every
Longhorn volume detaches, renumber all four cold, then on tars `systemctl stop k3s`, `k3s server
--cluster-reset` (resets membership to this node at its current address, reusing the existing data
dir, and leaves a guard file against a second reset), `systemctl start k3s`. On case and kipp: stop
k3s, `rm -rf /var/lib/rancher/k3s/server/db/`, start k3s to rejoin.
`--cluster-reset-restore-path=<snapshot>` is the next step down if the plain reset
fails[^k3s-etcd-snapshot].

# Checks

```bash
ssh tars kubectl get nodes -o wide                 # four Ready, new InternalIPs
ssh tars curl -k https://192.168.1.20:6443/livez   # the VIP answers
ssh tars kubectl get volumes -n longhorn-system    # nothing faulted
```

Addresses baked into the cluster's own config — an NFS server address, scrape targets naming node
IPs — live in the k8s-config repo and move in their own window.

# Related

* [hosts/nyx-cluster](/hosts/nyx-cluster.md) — the addressing, the VIP and the firewall table being changed.
* [nyx-bootstrap](nyx-bootstrap.md) — cert reissue, label/taint reconciliation, per-host facts.
* [decisions/firewall-source-scoping](/decisions/firewall-source-scoping.md) — why the allow-set is source-scoped, which is what makes it the thing to widen.
* [rebuild](rebuild.md) — `--target-host` and `--build-host`.
