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
            configurationLimit = 10;
          };

          grub = {
            enable = lib.mkDefault false;
            efiSupport = true;
            devices = [ "nodev" ];
          };

          limine = {
            enable = lib.mkDefault true;
            maxGenerations = 10;
            secureBoot.enable = cfg.secureBoot;

            style = {
              wallpapers = [
                "${
                  custom.assets.images.backgrounds.black-sand-dunes.${custom.config.resolution}
                }/share/backgrounds/black-sand-dunes.${custom.config.resolution}.jpeg"
              ];
              interface.branding = config.networking.hostName;
            };
          };
        };
      };
    };
}
