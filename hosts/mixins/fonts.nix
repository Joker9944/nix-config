{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "fonts" {
  fonts.packages = with pkgs; [
    lato
    roboto
    texlivePackages.opensans
    texlivePackages.nunito
  ];
}
