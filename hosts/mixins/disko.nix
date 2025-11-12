{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [ inputs.disko.nixosModules.disko ];

  options.mixins.hardware.disko =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      enable = mkEnableOption "disko config mixin";

      main = {
        name = mkOption {
          type = types.nullOr types.str;
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
            type = types.nullOr types.str;
            default = null;
            example = "40G";
            description = ''
              Size of the swap file. The swap file is part of the main partition.

              ram_size + round(sqrt(ram_size)))

              32 + round(sqrt(32)) = 38
            '';
          };

          main = mkOption {
            type = types.str;
            default = "100%";
            example = "-100G";
            description = ''
              Size of the main partition.

              - round(disk_size * 0.1)
            '';
          };
        };
      };
    };

  config.disko.devices.disk.main =
    let
      cfg = config.mixins.hardware.disko;
      devicePath = "/dev/${cfg.main.name}";
    in
    lib.mkIf (cfg.enable && cfg.main.name != null) {
      device = devicePath;
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
