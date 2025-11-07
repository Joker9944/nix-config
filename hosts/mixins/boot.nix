{
  inputs,
  lib,
  config,
  pkgs,
  custom,
  ...
}:
{
  # WORKAROUND Secure Boot for Limine is only available on unstable, so just override the module from unstable.
  # https://wiki.nixos.org/wiki/Limine
  disabledModules = [ "system/boot/loader/limine/limine.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/system/boot/loader/limine/limine.nix" ];

  options.mixins.boot =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "boot config mixin";
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
            secureBoot.enable = true;

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
