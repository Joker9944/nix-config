{ mkMixinModule, ... }:
{
  lib,
  pkgs,
  config,
  custom,
  ...
}:
mkMixinModule "limine" {
  environment.systemPackages = [ pkgs.sbctl ]; # secure boot util

  boot.loader = {
    efi.canTouchEfiVariables = true; # required for secure boot

    limine = {
      enable = true;
      maxGenerations = 10;
      secureBoot.enable = lib.mkDefault true;

      style = {
        wallpapers = [ "${custom.assets.black-sand-dunes}" ];
        interface.branding = config.networking.hostName;
      };
    };
  };
}
