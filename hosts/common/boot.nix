{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # WORKAROUND Secure Boot for Limine is only available on unstable, so just override the module from unstable.
  # https://wiki.nixos.org/wiki/Limine
  disabledModules = ["system/boot/loader/limine/limine.nix"];
  imports = [
    (import "${inputs.nixpkgs-unstable}/nixos/modules/system/boot/loader/limine/limine.nix")
  ];

  environment.systemPackages = [pkgs.sbctl];

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
        devices = ["nodev"];
      };

      limine = {
        enable = lib.mkDefault true;
        maxGenerations = 10;
        secureBoot.enable = true;

        style = {
          wallpapers = [];
          backdrop = "000000";
          interface.branding = config.networking.hostName;
        };
      };
    };
  };
}
