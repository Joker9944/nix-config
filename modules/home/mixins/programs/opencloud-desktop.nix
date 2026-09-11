{ mkMixinModule, ... }:
{ pkgs-unstable, ... }:
mkMixinModule "opencloud-desktop" {
  programs.opencloud-desktop = {
    enable = true;
    package = pkgs-unstable.opencloud-desktop;
  };
}
