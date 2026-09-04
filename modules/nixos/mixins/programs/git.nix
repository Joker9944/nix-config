{ mkMixinModule, ... }:
mkMixinModule "git" {
  programs.git.enable = true;
}
