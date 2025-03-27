{
  disks,
  swapSize,
  ...
}: {
  disko.devices = {
    disk = {
      main = {
        device = builtins.elemAt disks 0;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            luks = {
              size = "100%";

              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;

                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];

                  subvolumes = {
                    "root" = {
                      mountpoint = "/";
                    };

                    "home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd"];
                    };

                    "nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };

                    "swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = swapSize;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
