---
type: Decision
title: Geo-blocking runs at the edge, as an ipset allowlist
description: Public ingress is geo-filtered on wopr by an iptables rule matching a geoblock ipset populated from db-ip, replacing a Traefik middleware that resolved every client address against an external API in the request path.
tags: [decision, networking, ingress, firewall, geoblocking]
generated:
  by: claude-code/claude-opus-5
  at: 2026-11-12T00:00:00Z
---

# The rule

[wopr](/hosts/wopr.md) accepts `:443` only from sources in the `geoblock4` / `geoblock6` ipsets.
`modules/nixos/hosts/wopr/geoblock/` holds the country list, `flake.lib.network.mkAllowFromSet`
renders the rules, and `update-geoblock.service` populates the sets from db-ip country-lite daily.
Traefik keeps the per-router IP whitelists, which still see the real client address over PROXY
protocol.

The decision is **global**, because `proxy.nix` is an L4 splice with no SNI map — the edge cannot
tell one hostname from another, and giving it that ability would make it a place where ingress is
defined. Per-hostname geo rules are therefore not possible here at all, only in Traefik.

The country list is the one volatile part, so it stays declarative in nix and the prefix data does
not: 64k prefixes would make every refresh a multi-MB diff, which is why this is not vendored the way
[vendored-schemes](vendored-schemes.md) is. Widening is a commit plus a rebuild over tailscale;
`ipset add geoblock4 <prefix>` admits one network before that lands, and the next db-ip release,
country or `maxElem` change, or reboot reconciles it away.

# Why not the Traefik middleware it replaces

`PascalMinder/geoblock` resolved each client address against `get.geojs.io` **in the request path**.
That put a third party in the availability and privacy path of every public request, and decided only
after the traffic had already crossed the tunnel. Dropping in the kernel on the only internet-facing
host removes both. It is the same property [edge-not-a-cluster-node](edge-not-a-cluster-node.md)
bought for the tunnel itself.

# Why ipset rather than nftables sets

`networking.nftables.enable` sets `boot.blacklistedKernelModules = [ "ip_tables" ]` and flips
`networking.firewall.backend`, which then asserts `extraCommands == ""`. Admin SSH here is
tailscale-only with `:22` closed and the NixOS tailscale module exposes no firewall-mode option, so
tailscaled's own iptables→nftables fallback would have to be right the first time with only the
provider console as recovery. ipset needs no backend switch, keeps `mkAllowFrom` working, and is what
`networking.firewall.extraPackages` documents itself for. It also leaves
[firewall-source-scoping](firewall-source-scoping.md)'s iptables choice intact rather than
contradicting it on one host.

`extraCommands` only guarantees the sets exist, creating them empty when missing: a `-m set` rule
against a missing set aborts the firewall start script, and the populating unit cannot be ordered
before `firewall.service`. Their parameters belong to the update unit, which swaps them in. A
`create -exist` with a differing `maxelem` errors, the failed reload stops the firewall, and the host
is left unfiltered.

# Why db-ip rather than RIR data

geojs is GeoLite2-derived, so the behaviour being preserved is **geolocation**, not RIR allocation.
Measured for `ch`+`dk`+`pt`: ipdeny's RIR-aggregated zones give 5,788 prefixes, db-ip gives 9,786 v4
and 53,898 v6. The gap is not noise — RIR data attributes a block to the country its LIR registered
in, so a CH user on a carrier whose pool is registered abroad is absent from the CH zone and would be
locked out despite getting in today. db-ip needs no account and ships plain `start,end,cc` CSV, so
there is no mmdb walk; GeoLite2 via `services.geoipupdate` would match geojs exactly at the cost of
one sops secret and a locations-CSV join.

Two consequences of a prefix set rather than a live lookup: it is a **complete partition**, so
db-ip's `ZZ` unknown ranges drop where an API default might have admitted them; and a reassigned
block takes up to a month to appear.

# Fail-open on stale, fail-closed on empty

The update unit loads the cached database before it touches the network, so a boot or a firewall
restart repopulates without waiting on a fetch and a failed refresh keeps the last good data. It
skips that load when a digest in `/run/geoblock` of the cache and the unit's arguments matches and
neither set is empty — a size comparison alone cannot see contents changing at equal length. A
published month never changes, so nothing is downloaded while the cached month is current, and only a
404 falls back to the previous one.

A short, shrinking or over-`maxElem` dataset is rejected rather than installed — an empty allowlist
is a total outage and the only failure here that cannot recover on its own. Both families are built
before either is swapped, and the cache is replaced only after they are live. A failed refresh that
still serves the cache exits 2, failing the unit visibly without a restart loop; the one fail-closed
case, a cold start with nothing to serve, exits 1 and systemd retries. An unreadable cache is
discarded as a cold start.

# Related

* [hosts/wopr](/hosts/wopr.md) — where the rules and the unit live.
* [firewall-source-scoping](firewall-source-scoping.md) — `:443` is scoped by this, leaving the
  WireGuard port as the host's only unscoped one.
* [architecture/custom-lib](/architecture/custom-lib.md) — where `mkAllowFromSet` sits next to
  `mkAllowFrom`.
