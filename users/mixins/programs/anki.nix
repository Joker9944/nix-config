{ mkMixinModule, ... }:
mkMixinModule "anki" {
  programs.anki = {
    enable = true;
  };
}
