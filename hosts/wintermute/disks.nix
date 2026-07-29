{
  custom,
  inputs,
  ...
}:
{
  imports = [ inputs.disko.nixosModules.disko ];

  # Disk setup
  disko.devices = custom.lib.disko.mkDiskoLayout {
    config.main = {
      name = "nvme0n1";
      size = {
        boot = "1G";
        main = "-228G"; # 100G over provisioning + 128G Windows
        swap = "20G";
      };
    };
  };
}
