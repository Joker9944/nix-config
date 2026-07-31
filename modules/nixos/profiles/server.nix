{ flake, ... }:
{
  imports = [ flake.nixosModules.profiles-base ];

  mixins = {
    boot.loader.systemdBoot.enable = true;

    services.openssh.enable = true;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;
  networking.useDHCP = false;
}
