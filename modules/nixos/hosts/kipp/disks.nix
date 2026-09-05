{ inputs, flake, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

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
