---
type: Decision
title: The ingress edge is not a cluster node
description: Public ingress terminates on a non-member VPS that proxies to the in-cluster Traefik over a dedicated plain-WireGuard tunnel; joining it to k3s, riding the tailnet, running the cluster side as a pod, DNATing, or using the Tailscale operator were all rejected.
tags: [decision, networking, k3s, ingress, wireguard, tailscale]
generated:
  by: claude-code/claude-opus-5
  at: 2026-11-03T00:00:00Z
---

# The rule

[wopr](/hosts/wopr.md) restores public ingress over a **dedicated plain-WireGuard tunnel**: nginx
`stream` splices `:443` to an nginx upstream across the three servers' transit addresses on
Traefik's `websecure-proxied` NodePort. It is not a k3s node. The tunnel carries public traffic
only — `kubectl`, the private subdomains and wopr's own admin access stay on the tailnet, so the two
overlays are split by trust tier rather than one replacing the other.

Addressing, public keys and the NodePort are `flake.lib.network.wgEdge`; the spoke half lives in the
`k3s` mixin behind its `isServer` gate, uniform across the three servers.

# Why not a k3s node

Flannel routes by the address each node registers for itself, and every node must be reachable at
the address every other node advertises. There is no supported per-node split, so one off-LAN node
means moving the **whole** cluster dataplane onto a tunnel — pod MTU drops cluster-wide and
Longhorn replication and NFS media traffic pay for it. Calico with `vxlanMode: CrossSubnet` avoids
the encryption cost between the three LAN nodes but not the single global pod MTU, and buys that
with a separately-versioned CNI plus a live flannel migration that restarts every pod and detaches
every Longhorn volume.

The trust boundary is the other half. The exposure model
([firewall-source-scoping](firewall-source-scoping.md)) assumes LAN-or-tailnet; a public VPS as a
member makes the most-attacked machine a kubelet inside it. Taints and NetworkPolicy narrow pod
lateral movement, but a node compromise is not a NetworkPolicy problem.

# Why a tunnel of its own rather than the tailnet

Primary-router election is a control-plane function and the `192.168.1.128/25` route only exists in
wopr's table because the coordination server put it there, so riding the tailnet puts a third party
in the liveness path of **public** ingress. A static tunnel has no such dependency once the keys are
in sops.

The HA objection that previously ruled this out assumed the shared MetalLB VIP as the tunnel
destination, which does force one route onto three peers — `AllowedIPs` *is* the routing table.
Targeting a per-server transit `/32` instead makes the sets disjoint, so one interface carries all
three peers and failover moves into the nginx upstream (`max_fails`/`fail_timeout`, open-source
nginx's stream module). That is also faster than election: a TCP connect failure, not a control-plane
round trip.

The direction is forced either way — with no public IP the cluster cannot be the listener, so wopr
holds `ListenPort` and each server sets `Endpoint` and `PersistentKeepalive`. Nothing has to be
punched, since wopr's address is public and static.

A second win: `tailscale0` bypasses `networking.firewall` entirely
([firewall-source-scoping](firewall-source-scoping.md)), while `wg0` is deliberately **not** a
trusted interface, so `mkAllowFrom` scopes the edge's whole reach across the tunnel to one port on
three hosts. The Tailscale ACL stays necessary regardless — wopr is still a tailnet member and
`6443`/`10250`/`9100` are wildcard-bound — but it is now defence in depth rather than the only
control.

# Why the cluster side is a host process

A privileged gateway pod would need one keypair instead of three and would get failover from the
scheduler. It loses on four counts: pod→pod needs no SNAT, so Traefik would see the gateway pod's
dynamic address and `trustedIPs` would have to widen to the pod CIDR (the same flaw as the operator,
below); scheduler failover is eviction-timeout slow where nginx is connect-timeout fast; the tunnel
would depend on the scheduler, CNI and etcd staying healthy, which is the correlated failure the
change exists to remove; and the private key would move from host-key-bound sops into etcd.

# Why not kernel DNAT

`networking.nat.forwardPorts` needs masquerade, not just DNAT: the cluster's default route leaves by
its own CGNAT'd uplink, so a preserved client source address would never get its replies back
through the tunnel. Masquerading destroys the client IP, and a PROXY header cannot be injected from
the kernel path — which rules it out, because geo-blocking and IP whitelisting run on that address.
It would also need MSS clamping that the proxy design makes unnecessary.

# Why not the Tailscale Kubernetes operator

Its L7 Ingress provisions a MagicDNS name with a Tailscale-managed certificate via Serve and
supports no custom domain, so public clients would be served a `*.ts.net` certificate for a
`vonarx.online` hostname. The L4 `loadBalancerClass: tailscale` path does fit, and a `ProxyGroup`
with two replicas gives it real HA — but it depends on Tailscale's *control-plane API* (OAuth
clients, programmatic device registration, tag ownership), the surface headscale implements least
completely, whereas route advertisement and approval are core functionality it does support. Its
source-address behaviour is also undocumented; if the proxy masquerades, `trustedIPs` widens from
one address to the pod CIDR and any pod in the cluster can forge a client address past the geo and
whitelist rules.

The choice stays cheap to revisit: it is the nginx upstream and the `trustedIPs` value, nothing
else.

# Deferred

Self-hosting headscale on the edge is what removes the third party from the **private** path; the
public path no longer has one. It is a separate project: nothing here changes when `--login-server`
flips.

# Related

* [hosts/wopr](/hosts/wopr.md) — what the decision produced.
* [hosts/nyx-cluster](/hosts/nyx-cluster.md) — the spoke half of the tunnel and the wildcard-bound ports the ACL still has to cover.
* [host-profiles](host-profiles.md) — why the edge is `server` plus host deltas rather than its own profile.
