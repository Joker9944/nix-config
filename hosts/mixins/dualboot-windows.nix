{ lib, config, ... }:
{
  options.mixins.boot.windowsSupport =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "Windows dual boot config mixin";
    };

  config =
    let
      cfg = config.mixins.boot.windowsSupport;
    in
    lib.mkIf cfg.enable {
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
