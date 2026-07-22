{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "tailscale" {
  services.tailscale.enable = lib.mkDefault true;
}
