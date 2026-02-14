{
  lib,
  config,
  pkgs,
  custom,
  ...
}:
{
  options.mixins.boot =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "boot config mixin";
      secureBoot = mkEnableOption "secure boot" // {
        default = true;
      };
    };

  config =
    let
      cfg = config.mixins.boot;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.sbctl ];

      boot = {
        initrd.systemd.enable = true;

        loader = {
          efi.canTouchEfiVariables = true;

          systemd-boot = {
            enable = lib.mkDefault false;
            consoleMode = "max";
          };

          grub = {
            enable = lib.mkDefault false;
            efiSupport = true;
            devices = [ "nodev" ];
          };

          limine = {
            enable = lib.mkDefault true;
            secureBoot.enable = cfg.secureBoot;

            style = {
              wallpapers = [
                "${custom.assets.black-sand-dunes}/share/backgrounds/black-sand-dunes.jpeg"
              ];
              interface.branding = config.networking.hostName;
            };
          };
        };
      };
    };
}
