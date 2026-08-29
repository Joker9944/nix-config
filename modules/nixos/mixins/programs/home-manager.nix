{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "home-manager" {
  environment.systemPackages = [ pkgs.home-manager ];
}
