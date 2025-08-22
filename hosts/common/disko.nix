{
  config,
  lib,
  ...
}:
let
  cfg = config.hardware.disko.main;
  devicePath = "/dev/${cfg.name}";
in
{
  options.hardware.disko.main = with lib; {
    name = mkOption {
      type = lib.types.nullOr types.str;
      default = null;
      example = "sda";
      description = ''
        Name of the disk that should be used as main disk.
      '';
    };

    size = {
      boot = mkOption {
        type = types.str;
        default = "500M";
        description = ''
          Size of the boot partition.
        '';
      };

      swap = mkOption {
        type = lib.types.nullOr types.str;
        default = null;
        example = "40G";
        description = ''
          Size of the swap file. The swap file is part of the main partition.
        '';
      };

      main = mkOption {
        type = types.str;
        default = "100%";
        example = "-100G";
        description = ''
          Size of the main partition.
        '';
      };
    };
  };

  config.disko.devices.disk.main = lib.mkIf (cfg.name != null) {
    device = devicePath;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          end = cfg.size.boot;
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        luks = {
          end = cfg.size.main;

          content = {
            type = "luks";
            name = "crypted";
            settings.allowDiscards = true;

            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

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

                "swap" = lib.mkIf (cfg.size.swap != null) {
                  mountpoint = "/swap";
                  swap.swapfile.size = cfg.size.swap;
                };
              };
            };
          };
        };
      };
    };
  };
}
