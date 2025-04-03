{...}: {
  # Disk setup
  disks.main = {
    name = "nvme1n1";
    size = {
      disk = 1000000;
      swap = 40000;
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
          size = "1900000M";
          content = {
            type = "filesystem";
            format = "xfs";
            mountpoint = "/mnt/games";
            mountOptions = ["defaults" "nofail"];
          };
        };
      };
    };
  };
}
