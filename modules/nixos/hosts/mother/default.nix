{ flake, ... }@args:
# NAS worker: k3s agent + ZFS (chronos) + NFS. Joins via the kube-vip endpoint.
# hardware-configuration.nix is generated on the machine at rollout.
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;
    inherit args;
  }
  {
    networking = {
      hostName = "mother";
      # TODO set a unique 8-hex hostId (required by ZFS); e.g. `head -c4 /dev/urandom | od -A none -t x4`.
      hostId = "deadbeef";
    };

    systemd.network.networks."10-lan" = {
      matchConfig.Name = "en*";
      address = [ "192.168.0.24/23" ];
      routes = [ { Gateway = "192.168.1.1"; } ];
      dns = [ "192.168.1.1" ];
      linkConfig.RequiredForOnline = "routable";
    };

    services.k3s = {
      role = "agent";
      serverAddr = "https://192.168.0.20:6443";
      nodeLabel = [
        # TODO port the vonarx.online/* labels from the Talos node config.
        "vonarx.online/role=storage"
      ];
    };

    # Import the existing chronos pool (8×SATA HDD). Encrypted datasets load their
    # key from a keyfile via `zfs load-key` (not requestEncryptionCredentials,
    # which would prompt and hang an unattended reboot).
    boot.zfs.extraPools = [ "chronos" ];

    # LAN exports (the former nfs-host role). TODO fill real export paths/options.
    services.nfs.server.exports = ''
      /export  192.168.0.0/23(rw,sync,no_subtree_check)
    '';

    system.stateVersion = "26.05";
  }
