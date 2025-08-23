{
  lib,
  config,
  ...
}:
let
  cfg = config.boot.windowsSupport;
in
{
  options.boot.windowsSupport = with lib; {
    enable = mkEnableOption "dual boot bootloader config";
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
