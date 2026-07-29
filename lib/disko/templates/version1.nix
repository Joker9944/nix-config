{ lib, config, ... }:
{
  disk.main = {
    device = "/dev/${config.main.name}";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          end = config.main.size.boot;
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        luks = {
          end = config.main.size.main;

          content = {
            type = "luks";
            name = "crypted";
            settings.allowDiscards = true;

            content = {
              type = "btrfs";
              extraArgs = [ "--force" ]; # Override existing partition

              subvolumes = {
                "root" = {
                  mountpoint = "/";
                };

                "home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" ];
                };

                "nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "swap" = lib.mkIf (config.main.size.swap != null) {
                  mountpoint = "/swap";
                  swap.swapfile.size = config.main.size.swap;
                };
              };
            };
          };
        };
      };
    };
  };
}
