---
type: Host
title: wopr
description: A small VPS that restores public ingress after the cluster lost its public IP — an L4 splice from :443 to the in-cluster Traefik over a dedicated WireGuard tunnel, deliberately not a cluster member.
tags: [host, server, edge, ingress, wireguard, tailscale, nginx]
generated:
  by: claude-code/claude-opus-5
  at: 2026-11-06T00:00:00Z
---

# What it is

A 2-core/4 GB VPS, `profile = "server"`, and the only host the internet can reach: the
[nyx cluster](nyx-cluster.md)'s internet plan carries no public IP. It terminates no TLS, holds no
certificates and makes no per-hostname decisions — Traefik in the cluster stays the sole owner of
ingress rules, ACME, geo-blocking and IP whitelisting. Why it is not a k3s node is
[decisions/edge-not-a-cluster-node](/decisions/edge-not-a-cluster-node.md).

Its `mixins.nix` is absent: `base` + `server` already carry everything it needs, and a VPS guest
wants no CPU-vendor capability (microcode and kvm modules are the host's concern). It is the only VM
here, so `services.qemuGuest` is a host delta rather than a mixin — `profiles/qemu-guest.nix` in the
harvested hardware config carries the virtio modules but starts no agent, and without it the
provider's console loses graceful shutdown and snapshot fsfreeze. Single NIC, so
`matchConfig.Name` globs `en* eth0`. NixOS names the NIC **`ens3`** here, so the `en*` half is what
matches; `eth0` is kept because the provider's own images use that name and the glob costs nothing. Addressing is **static**, v4 and v6: there is no
DHCP server on the segment, so `DHCP=yes` would bring the host up with no network and no
console-free way back. The provider routes the whole `/64` here, so the v6 host part is
chosen: a random stable suffix, not `::1` (every v6 scanner's first guess) and not the EUI-64 value
(which encodes the VM's MAC, so it changes if the VM is rebuilt). The gateway is link-local, and
`IPv6AcceptRA` is off because v6 is static end to end — an RA would add a SLAAC address and a
competing default route on top. nginx carries a separate `listen [::]:443`, so `:443` serves both
families while the tunnel to the cluster stays v4. A client's v4 and v6 addresses are unrelated, so
every geo rule and IP whitelist Traefik applies has to cover both families per party — a v4-only
whitelist locks out the same client arriving over v6, which browsers prefer. Disks come from the `server-longhorn-v1`
template with
`longhorn` left at its `null` default, which gates that partition off and leaves a plain ESP plus
btrfs `root`/`home`/`nix`.

# The splice

`services.nginx.streamConfig` — one `server` on `:443` with `proxy_protocol on`, passing to an
`upstream` generated from `flake.lib.network.wgEdge.spokes`. No `ssl_preread` and no SNI map: every
hostname goes to the same backend, because Traefik already decides what is served. The generated
`nginx.conf` has an `http` block with no `server` in it, so nothing listens on `:80` and no
suppression is needed.

The upstream is also where failover lives — `max_fails`/`fail_timeout` per spoke, which is passive
health checking in open-source nginx's stream module (`health_check` is Plus). `proxy_connect_timeout`
is short because a node whose Traefik pod is missing may drop rather than reject under
`externalTrafficPolicy: Local`.

It **proxies rather than routes**, which is load-bearing twice over. Terminating the TCP connection
means each side negotiates MSS against its own path, so the tunnel hop cannot blackhole large
responses — a DNAT design would need MSS clamping in `FORWARD`. It also means the client address has
to travel out of band, hence PROXY protocol.

`:443` is the only public TCP port, and keeping it that way takes an override: the `openssh` mixin
leaves `openFirewall` at its `true` default, which would publish 22 here, so this host sets it
`false`. Admin SSH arrives over `tailscale0`, which bypasses `networking.firewall` regardless. Any
service mixin enabled on this host needs the same check. ACME is DNS-01, so there is no HTTP-01
challenge to serve and no redirect is offered; a plain `http://` request is refused at the TCP level
by design.

# The Traefik entrypoint

The backend is Traefik's **sole** `websecure` entrypoint, exposed as a NodePort Service with
`proxyProtocol.trustedIPs` set to this host's transit address. It can require the header on every
connection because nothing reaches the ingress directly: internal services are tailnet services
provisioned by the Tailscale operator ([nyx-cluster](nyx-cluster.md)), and there is no
load-balancer VIP. A consequence: the NodePort refuses a plain `curl`, so probes
against it must speak PROXY protocol.

`trustedIPs` being exactly one address is the point. A PROXY header is forgeable by anything inside
the trusted range, so widening it would let its source spoof a client address past the geo and
whitelist rules. That is why the Service is `externalTrafficPolicy: Local` — under `Cluster`,
kube-proxy SNATs to a node address when it forwards to a pod elsewhere, and `trustedIPs` would have
to widen to the node set. `Local` also means only a node running a Traefik pod can serve, which the
`vonarx.online/ingress-spoke` node label is there to guarantee.

`trustedIPs` is the control here, not the firewall: a NodePort is DNATed ahead of `nixos-fw`, so the
port answers anything that can route to a node — see
[firewall-source-scoping](/decisions/firewall-source-scoping.md).

# Reaching the cluster

`wireguard/default.nix` holds the **hub** of a dedicated WireGuard tunnel: this host has the public
address, so it carries `listenPort` and the CGNAT'd servers dial in. One `wg0` with three peers,
each `AllowedIPs` a single transit `/32` — disjoint, which is what lets them share an interface.
Why a tunnel of its own rather than the tailnet route is
[decisions/edge-not-a-cluster-node](/decisions/edge-not-a-cluster-node.md).

It is still a tailnet member — `base` enables Tailscale — but a plain leaf: no `useRoutingFeatures`,
no `--accept-routes`, so it holds no route into `192.168.1.0/23` at all. That is what keeps admin
SSH working while removing the LAN path.

Three things are outside nix. The node must be approved after `tailscale up` (there is no
`authKeyFile` anywhere in this repo). The private key must be in
`wireguard/secrets/wireguard.yaml`, which needs this host's age recipient in `.sops.yaml` before the
first activation. And a **Tailscale ACL** is still not optional hardening: `tailscale0` bypasses
`networking.firewall` entirely, and `6443`, `10250` and `9100` are wildcard-bound on the cluster
nodes, so an un-ACL'd edge reaches the Kubernetes API over every server's `100.64.x` address even
with no subnet route.

# Firewall

`:443` and the WireGuard port are the one peer set here that genuinely is every source on every
interface, which is why `allowedTCPPorts` and `allowedUDPPorts` are used on this host and nowhere
else — the exception [decisions/firewall-source-scoping](/decisions/firewall-source-scoping.md)
reserves, not a violation of it. `:443` is open to the internet by definition, and the tunnel port
cannot be scoped either: the spokes dial from a CGNAT'd uplink with no stable source address. The
exposure is small, since WireGuard answers an unauthenticated packet with silence.

`9100` is absent from that list and scoped by `mkAllowFrom` to the three spoke addresses instead:
Prometheus scrapes over the tunnel, and `wg0` is not a trusted interface, so the rule is what admits
it. node-exporter keeps its default **wildcard** bind, which leaves the port answering every tailnet
peer whatever the rules say — `tailscale0` bypasses `nixos-fw` entirely, so only a Tailscale ACL
closes that. The same posture the cluster's own node-exporter has.

Binding the hub transit address instead looks strictly better and is not: it drags in a
`StartLimitIntervalSec`/`RestartSec` workaround, because `wg0` is a networkd netdev and so has no
per-link unit whose completion means "the address exists" — `Restart=always` would otherwise exhaust
the start limit retrying a bind against an address that is not there yet. Socket activation with
`FreeBind` is the fix that would need neither, but this node-exporter build registers only
`--web.listen-address` and `--web.config.file`.

One cluster-side consequence this repo cannot assert: only a node that *is* a spoke can route to the
hub, so a Prometheus pod scheduled onto `mother` cannot scrape this host at all.
