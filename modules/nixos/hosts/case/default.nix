{ flake, ... }@args:
# HA server joining the cluster via the kube-vip endpoint (tars bootstraps it).
# hardware-configuration.nix is generated on the machine at rollout.
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;
    inherit args;
  }
  {
    networking.hostName = "case";

    systemd.network.networks."10-lan" = {
      matchConfig.Name = "en*";
      address = [ "192.168.0.22/23" ];
      routes = [ { Gateway = "192.168.1.1"; } ];
      dns = [ "192.168.1.1" ];
      linkConfig.RequiredForOnline = "routable";
    };

    services.k3s = {
      serverAddr = "https://192.168.0.20:6443";
      nodeLabel = [
        # TODO port the vonarx.online/* labels from the Talos node config.
        "vonarx.online/role=control-plane"
      ];
    };

    system.stateVersion = "26.05";
  }
