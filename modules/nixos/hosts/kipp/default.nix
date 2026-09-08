{ flake, ... }@args:
# HA server joining the cluster via the kube-vip endpoint (tars bootstraps it).
# hardware-configuration.nix is generated on the machine at rollout.
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;
    inherit args;
  }
  {
    networking.hostName = "kipp";

    systemd.network.networks."10-lan" = {
      matchConfig.Name = "en*";
      address = [ "192.168.0.23/23" ];
      routes = [ { Gateway = "192.168.1.1"; } ];
      dns = [ "192.168.1.1" ];
      linkConfig.RequiredForOnline = "routable";
    };

    # Subnet-route the kube-vip endpoint; see tars.
    services.tailscale = {
      useRoutingFeatures = "server";
      extraSetFlags = [ "--advertise-routes=192.168.0.20/32" ];
    };

    services.k3s = {
      serverAddr = "https://192.168.0.20:6443";
      # The API cert must carry the VIP or joiners reject it on a SAN mismatch.
      extraFlags = [ "--tls-san=192.168.0.20" ];
    };

    system.stateVersion = "26.05";
  }
