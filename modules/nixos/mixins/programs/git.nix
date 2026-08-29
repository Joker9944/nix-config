{ mkMixinModule, ... }:
{ lib, ... }:
mkMixinModule "git" {
  programs.git.enable = lib.mkDefault true;
}
