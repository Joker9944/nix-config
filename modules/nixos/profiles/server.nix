{ flake, ... }:
{
  imports = [ flake.nixosModules.profiles-base ];

  mixins = {
    boot.loader.systemdBoot.enable = true;

    services = {
      openssh.enable = true;
      ntp.enable = true;
    };
  };

  custom.greeting.modules = [
    "title"
    "uptime"
    "loadavg"
    "memory"
    "disk"
  ];

  networking.useNetworkd = true;
  systemd.network.enable = true;
  networking.useDHCP = false;
}
