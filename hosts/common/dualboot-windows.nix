{lib, config, ...}: let
  cfg = config.custom.boot.windows;
in {
  options.custom.boot.windows = with lib; {
    enable = mkEnableOption "dualboot bootloader config";
  };

  config = lib.mkIf cfg.enable {
    time.hardwareClockInLocalTime = true;

    boot.loader = {
      grub.useOSProber = true;

      limine.extraEntries = ''
        /Windows
          protocol: efi
          path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };
}
