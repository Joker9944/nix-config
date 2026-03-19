{
  # Disk setup
  mixins.hardware.disko = {
    enable = true;

    main = {
      name = "nvme0n1";
      size = {
        boot = "1G";
        main = "-228G";
        swap = "20G";
      };
    };
  };
}
