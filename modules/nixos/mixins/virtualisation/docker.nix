{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "docker" {
  virtualisation.docker.enable = lib.mkDefault true;
}
