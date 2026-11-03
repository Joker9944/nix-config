{ inputs, flake, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = flake.lib.disko.mkDiskoLayout {
    config.main = {
      name = "vda";
      size.boot = "1G";
    };
    template = flake.lib.disko.templates."server-longhorn-v1";
  };
}
