# PLACEHOLDER — regenerate on the machine with `nixos-generate-config` and
# commit the result. Filesystems are provided by disko (see disks.nix); this
# file supplies only the hardware-detected kernel/module bits. The values below
# are typical-NUC guesses so the config evaluates and builds before first boot.
_: {
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  hardware.cpu.intel.updateMicrocode = true;
}
