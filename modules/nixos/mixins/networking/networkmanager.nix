{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "networkmanager" {
  networking.networkmanager.enable = lib.mkDefault true;
}
