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
      address = [ "192.168.1.24/23" ];
      routes = [ { Gateway = "192.168.0.254"; } ];
      dns = [ "192.168.0.254" ];
      linkConfig.RequiredForOnline = "routable";
    };

    # Import the existing chronos pool. Nothing on it is encrypted, so the
    # boot-time import needs no key and cannot stall this headless machine on a
    # password prompt.
    boot.zfs.extraPools = [ "chronos" ];

    hardware = {
      # No X or console on the GPU, so nothing else keeps it initialised
      # between transcodes.
      nvidia.nvidiaPersistenced = true;

      # Generates the CDI specs containerd needs to hand the GPU to a pod.
      # Without it the driver works and containers still see no device.
      nvidia-container-toolkit.enable = true;
    };

    services = {
      k3s = {
        role = "agent";
        serverAddr = "https://192.168.1.20:6443";
        nodeTaint = [ "vonarx.online/reserved=storage:NoSchedule" ];
      };

      # chronos is 8 CMR HDDs plus an Optane SLOG; periodic trim has nothing
      # meaningful to reclaim. The btrfs root keeps services.fstrim.
      zfs.trim.enable = false;

      smartd = {
        # The member list is the inventory, so a drive that is gone is visible
        # in `systemctl status` and in the journal as a device smartd was told
        # about and could not register, rather than silently absent from a
        # DEVICESCAN. It has to be updated when a drive is replaced.
        #
        # It does NOT make absence alertable: a listed device that fails to
        # register is dropped with "Prevent retry of registration", so the
        # open-failure warning path never runs for it. Member absence belongs
        # to zed, which does alert on it. See /workflows/diagnose-disk-faults.
        autodetect = false;

        # Without this, one unregisterable device is fatal at startup and
        # nothing is monitored at all — the absent member would take the other
        # nine with it. The unit has no Restart=, so that death is permanent.
        extraOptions = [ "-q never" ];

        devices =
          let
            sata = wwn: {
              device = "/dev/disk/by-id/wwn-0x${wwn}";
              options = "-d sat";
            };
            nvme = eui: {
              device = "/dev/disk/by-id/nvme-eui.${eui}";
              options = "-d nvme";
            };
          in
          # WWN rather than the ata-*_<serial> form so an alert maps straight
          # onto a `zpool status` line; the serial identifies it in the chassis.
          map sata [
            "50014ee216f1caac" # WD-WX52D6595S6U
            "50014ee2c19d268f" # WD-WX62D656UTZF
            "50014ee2c083e7e4" # WD-WXP2D53H7NLK
            "50014ee215d82378" # WD-WXF2D53K625L
            "50014ee2161dc96e" # WD-WX42DA37PS27
            "50014ee2161df97a" # WD-WX12D93PD9J6
            "50014ee26b732b89" # WD-WX52D93K4FSC
            "50014ee26b70d757" # absent: ata8 PHY dead, awaiting a cable swap
          ]
          ++ [
            (nvme "e8238fa6bf530001001b448b4c1f4e59") # WD Red SN700, OS
            (nvme "5cd2e4b0161e0100") # Optane M10, chronos log; no self-tests
          ];
      };
    };

    system.stateVersion = "26.05";
  }
