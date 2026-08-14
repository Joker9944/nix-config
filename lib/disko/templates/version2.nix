{ lib, ... }:
{ config, ... }:
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

        swap = lib.mkIf (config.main.size.swap != null) {
          end = config.main.size.swap;

          content = {
            type = "luks";
            name = "crypted1";
            settings.allowDiscards = true;

            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
        };

        main = {
          end = config.main.size.main;

          content = {
            type = "luks";
            name = "crypted2";
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
              };
            };
          };
        };
      };
    };
  };
}
