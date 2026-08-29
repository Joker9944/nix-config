{ mkMixinModule, ... }:
{ lib, pkgs, ... }:
mkMixinModule "gnupg" {
  programs.gnupg = {
    package = pkgs.gnupg1;
    agent.enable = lib.mkDefault true;
  };
}
