{ inputs, flake, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  # OS SSD only. The chronos pool (8×HDD + an Optane SLOG on nvme1n1) is an
  # existing pool, imported via boot.zfs.extraPools in default.nix — never
  # disko-managed. Addressed by-id because the machine has two NVMe devices and
  # only one of them may be wiped.
  disko.devices = flake.lib.disko.mkDiskoLayout {
    config.main = {
      name = "disk/by-id/nvme-WD_Red_SN700_1000GB_23403L800001";
      size = {
        boot = "1G";
        longhorn = "300G";
      };
    };
    template = flake.lib.disko.templates."server-longhorn-v1";
  };
}
