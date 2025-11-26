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

      layoutVersion = mkOption {
        type = types.int;
        default = 1;
      };

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

  config =
    let
      cfg = config.mixins.hardware.disko;
    in
    lib.mkIf cfg.enable {
      mixins.hardware.disko.layoutVersion = lib.mkDefault 1;

      disko.devices = import ./layout-version-${toString cfg.layoutVersion}.nix { inherit lib cfg; };
    };
}
