{ lib, cfg, ... }:
{
  disk.main = {
    device = "/dev/${cfg.main.name}";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          end = cfg.main.size.boot;
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        luks = {
          end = cfg.main.size.main;

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

                "swap" = lib.mkIf (cfg.main.size.swap != null) {
                  mountpoint = "/swap";
                  swap.swapfile.size = cfg.main.size.swap;
                };
              };
            };
          };
        };
      };
    };
  };
}
