{lib, ...}: {
  # Set default bootloader settings
  boot = {
    initrd.systemd.enable = true;

    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = lib.mkDefault false;
        consoleMode = "max";
        configurationLimit = 10;
      };

      grub = {
        # GRUB setup
        enable = lib.mkDefault true;
        efiSupport = true;
        devices = [ "nodev" ];
      };
    };
  };
}
