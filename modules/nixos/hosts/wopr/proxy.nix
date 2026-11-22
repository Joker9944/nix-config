{ flake, ... }:
{ lib, ... }:
let
  wg = flake.lib.network.wgEdge;

  servers =
    port: extra:
    lib.concatMapStringsSep "\n" (spoke: "  server ${spoke.address}:${toString port}${extra};") (
      lib.attrValues wg.spokes
    );

  udpForward =
    { listen, nodePort }:
    let
      name = "udp_${toString listen}";
    in
    ''
      upstream ${name} {
      ${servers nodePort ""}
      }

      server {
        listen ${toString listen} udp;
        listen [::]:${toString listen} udp;
        proxy_pass ${name};
        proxy_timeout 30s;
        limit_conn udp 4;
      }
    '';
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
#
# The UDP forwards differ on each point. nginx re-sends every datagram, so one
# larger than the tunnel MTU fragments. There is no PROXY header the backend
# could parse, so limit_conn is the last place the client address is used. And
# there is no failover: without proxy_responses a UDP timeout never marks a peer
# failed, and a session stays pinned while the client keeps sending. Round-robin
# rather than a hash is what lets a client that reconnects from a new port land
# on another spoke.
{
  services.nginx = {
    enable = true;
    streamConfig = ''
      upstream cluster {
      ${servers wg.nodePort " max_fails=2 fail_timeout=10s"}
      }

      server {
        listen 443;
        listen [::]:443;
        proxy_pass cluster;
        proxy_protocol on;
        proxy_connect_timeout 2s;
      }

      limit_conn_zone $binary_remote_addr zone=udp:1m;

      ${lib.concatMapStringsSep "\n" udpForward wg.udpForwards}
    '';
  };
}
