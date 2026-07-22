{ mkMixinModule, ... }:
mkMixinModule "windowsSupport" {
  time.hardwareClockInLocalTime = true;

  boot.loader = {
    grub.useOSProber = true;

    limine.extraEntries = ''
      /Windows
        protocol: efi
        path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };
}
