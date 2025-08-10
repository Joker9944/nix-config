{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Lenovo ThinkPad X1 Yoga Gen 4
  # * https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_4)

  # Disk setup
  common.disks.main = {
    name = "nvme0n1";
    size = {
      main = "-100G";
      swap = "20G";
    };
  };

  boot = {
    # Manually add kernel modules which do net get picked up in hardware scan
    kernelModules = ["iwlwifi"];
    loader.limine.style.interface.brandingColor = 4; # blue
  };

  # Enable finger print reader service
  services.fprintd.enable = true;

  # Supports Linux Vendor Firmware Service (lvfs)
  services.fwupd.enable = true;

  # Override keyboard layout
  services.xserver.xkb = {
    layout = "ch";
    variant = "";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}
