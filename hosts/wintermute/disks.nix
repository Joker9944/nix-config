{
  # Disk setup
  mixins.hardware.disko = {
    enable = true;

    main = {
      name = "nvme0n1";
      size = {
        main = "-100G";
        swap = "20G";
      };
    };
  };
}
