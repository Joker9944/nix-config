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
          size = config.main.size.boot;
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        # Dedicated plain-xfs partition for Longhorn replicas. Optional: set
        # `longhorn = null` once a dedicated Longhorn disk exists, then mount
        # /var/lib/longhorn from a sibling disk block in the host's disks.nix.
        longhorn = lib.mkIf (config.main.size.longhorn != null) {
          size = config.main.size.longhorn;
          content = {
            type = "filesystem";
            format = "xfs";
            mountpoint = "/var/lib/longhorn";
            mountOptions = [
              "defaults"
              "nofail"
            ];
          };
        };

        main = {
          size = "100%";

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
}
