{
  config,
  lib,
  ...
}: let
  cfg = config.disks.main;
  devicePath = "/dev/${cfg.name}";
  sizeMain = cfg.size.disk - cfg.size.boot - cfg.size.empty;
in {
  options.disks.main = with lib; {
    name = mkOption {
      type = lib.types.nullOr types.str;
      default = null;
      example = "sda";
      description = ''
        Name of the disk that should be used as main disk.
      '';
    };

    size = {
      disk = mkOption {
        type = lib.types.nullOr types.int;
        default = null;
        example = 1000000;
        description = ''
          Total size of the main disk in MB.
        '';
      };

      boot = mkOption {
        type = types.int;
        default = 1000;
        description = ''
          Size of the boot partition in MB.
        '';
      };

      swap = mkOption {
        type = lib.types.nullOr types.int;
        default = null;
        example = 40000;
        description = ''
          Size of the swap file in MB, if null no swap file will be created.
        '';
      };

      empty = mkOption {
        type = types.int;
        default = 100000;
        description = ''
          Size of the empty space at the end of the disk used for overprovisioning in MB.
        '';
      };
    };
  };

  config.disko.devices.disk.main = lib.mkIf (cfg.name != null && cfg.size.disk != null) {
    device = devicePath;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "${toString cfg.size.boot}M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        luks = {
          size = "${toString sizeMain}M";

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

                "swap" = lib.mkIf (cfg.size.swap != null) {
                  mountpoint = "/swap";
                  swap.swapfile.size = "${toString cfg.size.swap}M";
                };
              };
            };
          };
        };
      };
    };
  };
}
