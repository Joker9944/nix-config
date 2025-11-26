{
  # Disk setup
  mixins.hardware.disko = {
    enable = true;

    main = {
      name = "nvme1n1";
      size = {
        boot = "1G";
        main = "-100G";
        # TODO Change to 38G if ever reformatting
        swap = "40G";
      };
    };
  };

  # Additional disk
  disko.devices.disk.games = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        # TODO rename to main if ever reformatting
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
