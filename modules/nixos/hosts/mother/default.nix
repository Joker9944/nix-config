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
      # The hostid chronos was last imported under, so the pool still imports
      # cleanly if the TrueNAS side is not exported gracefully.
      hostId = "6a82bded";
    };

    systemd.network.networks."10-lan" = {
      # Not en*: the board has a second onboard NIC (eno2) that is unpopulated,
      # and RequiredForOnline below would then wait on a link that never comes up.
      matchConfig.Name = "eno1";
      address = [ "192.168.0.24/23" ];
      routes = [ { Gateway = "192.168.1.1"; } ];
      dns = [ "192.168.1.1" ];
      linkConfig.RequiredForOnline = "routable";
    };

    # Import the existing chronos pool. Nothing on it is encrypted, so the
    # boot-time import needs no key and cannot stall this headless machine on a
    # password prompt.
    boot.zfs.extraPools = [ "chronos" ];

    services = {
      k3s = {
        role = "agent";
        serverAddr = "https://192.168.0.20:6443";
        nodeLabel = [
          # TODO port the vonarx.online/* labels from the Talos node config.
          "vonarx.online/role=storage"
        ];
      };

      # chronos is 8 CMR HDDs plus an Optane SLOG; periodic trim has nothing
      # meaningful to reclaim. The btrfs root keeps services.fstrim.
      zfs.trim.enable = false;

      # The path is the pool default: no dataset sets a local mountpoint, so an
      # import without an altroot mounts at /chronos/* (TrueNAS used altroot=/mnt).
      nfs.server.exports = ''
        /chronos/media-data  192.168.0.0/23(sec=sys,rw,no_subtree_check)
      '';
    };

    system.stateVersion = "26.05";
  }
