{ mkMixinModule, ... }:
mkMixinModule "direnv" {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
