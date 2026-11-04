{ flake, ... }@args:
# Public ingress edge node. The cluster's internet plan has no public IP, so this
# is the only host the internet can reach; it splices :443 to the in-cluster
# Traefik and decides nothing itself. Deliberately not a cluster member — see
# decisions/edge-not-a-cluster-node.
# hardware-configuration.nix is generated on the machine at rollout.
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;
    inherit args;
  }
  {
    networking.hostName = "wopr";

    # The only VM in the fleet. hardware-configuration.nix imports
    # profiles/qemu-guest.nix, which carries the virtio modules but starts no
    # agent, so the provider's console reports it missing and loses graceful
    # shutdown and snapshot fsfreeze.
    services.qemuGuest.enable = true;

    # Provider-assigned addressing, static: there is no DHCP server on this
    # segment, so DHCP would leave the host unreachable with no console-free
    # recovery. One NIC, so the glob is safe here in a way it is not on
    # tars/mother. NixOS names it ens3; eth0 is kept because the provider's own
    # images use that name and the glob costs nothing.
    #
    # The provider routes the whole 2a03:4000:15:19fc::/64 here, so the v6 host
    # part is ours to choose. A random stable suffix rather than ::1, which every
    # v6 scanner tries first, and rather than the EUI-64 value, which encodes the
    # VM's MAC and so changes if the VM is rebuilt.
    #
    # The v6 gateway is link-local. v6 is configured statically end to end, so
    # IPv6AcceptRA is off: an RA would otherwise add a SLAAC address and a
    # competing default route on top.
    systemd.network.networks."10-wan" = {
      matchConfig.Name = "en* eth0";
      address = [
        "62.83.98.27/22"
        "2a03:4000:15:19fc::9d4f:21c7/64"
      ];
      routes = [
        { Gateway = "62.83.96.1"; }
        { Gateway = "fe80::1"; }
      ];
      # The provider's resolvers first for latency, one public as fallback: a
      # provider DNS outage would otherwise block tailscaled re-auth and every
      # nix substituter. systemd-resolved is on (networking.useNetworkd pulls it
      # in), so these are its upstreams and the libc three-nameserver limit the
      # provider's resolv.conf warns about does not apply — which is why the
      # fourth one it ships commented out is included here.
      dns = [
        "46.38.252.230"
        "46.38.225.230"
        "2a03:4000:8000::fce6"
        "2a03:4000:0:1::e1e6"
        "1.1.1.1"
      ];
      networkConfig.IPv6AcceptRA = false;
      linkConfig.RequiredForOnline = "routable";
    };

    # No subnet routes accepted: ingress rides the WireGuard tunnel in
    # wireguard.nix, so this is a plain tailnet leaf with no route into
    # 192.168.1.0/23 at all. Tailscale stays enabled through base for admin SSH
    # and the node-exporter scrape.

    # The one host whose peer set really is every source on every interface,
    # which decisions/firewall-source-scoping reserves as its exception — the
    # spokes dial from a CGNAT'd uplink, so 51820 has no stable source to scope
    # to either. 9100 is deliberately absent: the firewall blocks it on the
    # public link, while tailscale0 bypasses the firewall entirely, which is how
    # Prometheus gets it.
    networking.firewall = {
      allowedTCPPorts = [ 443 ];
      allowedUDPPorts = [ flake.lib.network.wgEdge.endpoint.port ];
    };

    services.prometheus.exporters.node = {
      enable = true;
      openFirewall = false;
    };

    system.stateVersion = "26.05";
  }
