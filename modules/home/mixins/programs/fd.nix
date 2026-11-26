{ mkMixinModule, ... }:
mkMixinModule "fd" {
  programs.fd.enable = true;
}
