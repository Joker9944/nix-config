{ inputs, flake, ... }:
{ ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  # OS SSD only. The chronos pool (8×HDD) is an existing pool, imported via
  # boot.zfs.extraPools in default.nix — never disko-managed.
  # TODO confirm the OS SSD device name on the machine.
  disko.devices = flake.lib.disko.mkDiskoLayout {
    config.main = {
      name = "nvme0n1";
      size = {
        boot = "1G";
        longhorn = "300G";
      };
    };
    template = flake.lib.disko.templates."server-longhorn-v1";
  };
}
