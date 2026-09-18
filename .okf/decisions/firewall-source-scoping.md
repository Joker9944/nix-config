---
type: Decision
title: Firewall ports are scoped by source, on the iptables backend
description: Cluster ports go in `networking.firewall.extraCommands` scoped to their peers, not in `allowedTCPPorts`; the iptables backend stays, because `extraInputRules` would require switching the whole host firewall to nftables under a live k3s.
tags: [decision, networking, k3s, firewall]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-16T00:00:00Z
---

# The rule

`allowedTCPPorts` / `allowedUDPPorts` open a port to **every source on every interface**. For anything with a known set of peers — everything the [nyx cluster](/hosts/nyx-cluster.md) needs — the rule goes in `networking.firewall.extraCommands`, built by `flake.lib.network.mkAllowFrom` with an explicit source list.

# Why not nftables

`networking.firewall.extraInputRules` is the option the NixOS manual points at, and it is the wrong tool here: it works only when `networking.firewall.backend = "nftables"`, which means turning `networking.nftables.enable` on. k3s and kube-proxy install their own iptables rules, so flipping the host firewall backend under a running cluster is a real risk for no gain.

It buys nothing, because the iptables backend already runs `extraCommands` in exactly the right place. In `nixos/modules/services/networking/firewall-iptables.nix` the start script emits, in order: the `trustedInterfaces` accepts, the ESTABLISHED/RELATED accept, the `allowedTCPPorts` accepts, `${cfg.extraCommands}`, then the catch-all `-A nixos-fw -j nixos-fw-log-refuse`. Appending to `nixos-fw` therefore lands ahead of the refuse.

Three invariants follow and are why `mkAllowFrom` exists rather than hand-written rules: append (`-A`) to `nixos-fw`, jump to `nixos-fw-accept` rather than `ACCEPT`, and pass `-w` for the xtables lock. No `extraStopCommands` is needed — the stop script flushes `nixos-fw` wholesale. The rules are IPv4 only, where `allowedTCPPorts` went through `ip46tables`; the cluster is v4 throughout, so that closes v6 exposure rather than breaking anything.

# What this does not cover

`networking.firewall` does not apply to the tailnet **at all**. tailscaled runs with the default `--netfilter-mode=on`, which inserts its own `ts-input` chain at the head of `INPUT` with an accept for everything arriving on `tailscale0` — ahead of the `-A INPUT -j nixos-fw` jump. No `allowedTCPPorts` entry, `trustedInterfaces` entry or `extraCommands` rule is consulted for a tailnet packet, on any host in this repo (the base profile enables tailscale everywhere).

So on a node, any port bound to `0.0.0.0` is reachable by anything on the tailnet regardless of these rules. What actually keeps the cluster's internal ports off the tailnet is their **bind address**, not the firewall: kube-proxy (`10249`), etcd (`2379`/`2380`) and the metallb speaker (`7946`) listen on the node's LAN address only, while kube-apiserver (`6443`), kubelet (`10250`) and node-exporter (`9100`) listen on `0.0.0.0` and answer any tailnet peer. Verified by probing a node from a tailnet host: exactly the wildcard-bound ports answered.

That is why the kube-proxy `metrics-bind-address` is the node address rather than `0.0.0.0` — on this path the bind is the control, and the firewall rule is not. The `100.64.0.0/10` source on the `6443` rule is kept as belt-and-braces for a future where tailscale's netfilter mode changes; it admits nothing today.

Turning the bypass off (`--netfilter-mode=off` or `nodivert`) is not a free tightening: the servers are subnet routers for the VIP, and hand-managing the rules tailscaled would stop installing is its own failure mode.

# Why the pod CIDR is in the allow-set

`10.42.0.0/16` is allowed on the scraped ports (`10250`, `9100`, `10249`) even though the node list alone suffices. Flannel's `ipMasq` **does** SNAT a pod's cross-node traffic to the sending node's address — verified by sourcing a connection from a node's `cni0` address (`10.42.0.1`) to another node's `2379`, which is allowed from node addresses only and succeeded. So the entry is redundant under current behaviour and kept only as insurance: if that stops holding, scraping breaks on all four nodes at once and nothing else changes visibly.

It is not a proof against spoofing. `services.tailscale` forces `checkReversePath = "loose"` whenever `useRoutingFeatures` is a server mode, and loose rpfilter will not drop a forged `10.42.x.x` source arriving on the LAN NIC. The trade is a non-routable range on three metrics ports against a silent cluster-wide monitoring outage.

# Related

* [hosts/nyx-cluster](/hosts/nyx-cluster.md) — the port-to-source table this produces.
* [enable-flag-mixins](enable-flag-mixins.md) — why the NFS rule sits on `mother` rather than becoming a mixin option: its source set is the same decision as the export ACL, and exports are a host delta.
* [architecture/custom-lib](/architecture/custom-lib.md) — where `mkAllowFrom` and `nyxNodes` live.
