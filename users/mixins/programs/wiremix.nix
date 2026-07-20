{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "wiremix" {
  home.packages = [ pkgs.wiremix ];
}
