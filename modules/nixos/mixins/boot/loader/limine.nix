{ mkMixinModule, inputs, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  assets = inputs.nix-assets.packages.${pkgs.stdenv.hostPlatform.system};
in
mkMixinModule "limine" {
  environment.systemPackages = [ pkgs.sbctl ]; # secure boot util

  boot.loader = {
    efi.canTouchEfiVariables = true; # required for secure boot

    limine = {
      enable = true;
      maxGenerations = 10;
      secureBoot.enable = lib.mkDefault true;

      style = {
        wallpapers = [ "${assets.black-sand-dunes}" ];
        interface.branding = config.networking.hostName;
      };
    };
  };
}
