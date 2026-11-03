/**
  WireGuard transit addressing for the public ingress tunnel between the edge
  (wopr) and the cluster servers. Data rather than a helper, because no host can
  be given just its own entry: the edge builds its peer list from every spoke,
  each spoke needs the hub, and the servers' firewall rule needs the hub address.

  Public keys are not secret and live here; private keys are per-host sops
  secrets. `nodePort` is Traefik's `websecure-proxied` entrypoint, shared between
  the edge's nginx upstream and the servers' firewall rule so the two cannot
  drift.
*/
_: {
  # The cluster is CGNAT'd and cannot listen, so the spokes dial wopr and the
  # direction is fixed. A literal address rather than a hostname: networkd does
  # not re-resolve an endpoint, so a name would silently pin to its boot-time
  # address.
  endpoint = {
    address = "62.83.98.27";
    port = 51820;
  };

  hub = {
    address = "10.100.0.254";
    publicKey = "yTw+ye8CSEvs/JYr8NwS6WFf6jPVZgeocOUUjB5Z3BI=";
  };

  # Last octet mirrors the node's LAN address in nyxNodes.nix. `mother` is an
  # agent and runs no Traefik pod, so it is not a spoke.
  spokes = {
    tars = {
      address = "10.100.0.21";
      publicKey = "jtjqVVN9zBWIdHsCw1PDsnCHtQQubvoxE1CcuATfxTI=";
    };
    case = {
      address = "10.100.0.22";
      publicKey = "+lp1L9jtLcNTMYcAQh/zImiA76/PWY4U1b+SiWrxvwQ=";
    };
    kipp = {
      address = "10.100.0.23";
      publicKey = "Ecq9KZ5ZdsxeqL/ql2A3WhkoRioRN0fntz23hUzljF4=";
    };
  };

  nodePort = 30443;
}
