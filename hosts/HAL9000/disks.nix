_: {
  # Disk setup
  hardware.disko.main = {
    name = "nvme1n1";
    size = {
      boot = "1G";
      main = "-100G";
      swap = "40G";
    };
  };

  # Additional disk
  disko.devices.disk.games = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        games = {
          end = "-100G";
          content = {
            type = "filesystem";
            format = "xfs";
            mountpoint = "/mnt/games";
            mountOptions = [
              "defaults"
              "nofail"
            ];
          };
        };
      };
    };
  };
}
