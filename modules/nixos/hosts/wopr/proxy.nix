{ flake, ... }:
{ lib, ... }:
let
  wg = flake.lib.network.wgEdge;

  servers = lib.concatMapStringsSep "\n" (
    spoke: "  server ${spoke.address}:${toString wg.nodePort} max_fails=2 fail_timeout=10s;"
  ) (lib.attrValues wg.spokes);
in
# An L4 splice, not an HTTP proxy: no TLS termination, no certificates and no
# per-hostname routing, so Traefik stays the only place ingress is defined.
# Terminating TCP rather than forwarding packets is what keeps the tunnel MTU
# off the end-to-end path; the cost is that the client address has to travel out
# of band, hence proxy_protocol.
#
# The backend is a dedicated Traefik entrypoint, reached over the WireGuard
# tunnel in wireguard.nix on a NodePort. Enabling PROXY protocol on the
# cluster's :443 instead would reject every tailnet client that reaches the
# ingress directly, since such a connection carries no header.
#
# Failover lives here rather than in the routing table: one upstream entry per
# spoke, marked down on a TCP connect failure. The short connect timeout matters
# because a node whose Traefik pod is missing may drop rather than reject under
# externalTrafficPolicy: Local.
{
  services.nginx = {
    enable = true;
    streamConfig = ''
      upstream cluster {
      ${servers}
      }

      server {
        listen 443;
        listen [::]:443;
        proxy_pass cluster;
        proxy_protocol on;
        proxy_connect_timeout 2s;
      }
    '';
  };
}
