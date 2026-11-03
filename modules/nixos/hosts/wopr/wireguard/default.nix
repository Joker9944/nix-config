{ flake, inputs, ... }:
{ config, lib, ... }:
let
  wg = flake.lib.network.wgEdge;
in
# Hub of the public ingress tunnel. This host has the public address, so it
# listens and the CGNAT'd servers dial in; there is no hole to punch and no
# relay. Private access stays on the tailnet — see
# decisions/edge-not-a-cluster-node.
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."wireguard/private-key".sopsFile = ./secrets/wireguard.yaml;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "${wg.hub.address}/32" ];
    listenPort = wg.endpoint.port;
    privateKeyFile = config.sops.secrets."wireguard/private-key".path;

    # Per-spoke /32s rather than the shared MetalLB VIP: disjoint AllowedIPs are
    # what let all three live on one interface, and failover then belongs to the
    # nginx upstream in proxy.nix instead of the routing table.
    peers = lib.mapAttrsToList (_: spoke: {
      inherit (spoke) publicKey;
      allowedIPs = [ "${spoke.address}/32" ];
    }) wg.spokes;
  };

  # The generated unit sets only Name and address, and a wireguard link that
  # never reaches routable would hang systemd-networkd-wait-online for its full
  # timeout — painful on a remote VPS.
  systemd.network.networks."40-wg0".linkConfig.RequiredForOnline = "no";
}
