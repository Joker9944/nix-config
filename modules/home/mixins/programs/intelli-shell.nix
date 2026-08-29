{ mkMixinModule, ... }:
mkMixinModule "intelli-shell" {
  programs.intelli-shell = {
    enable = true;

    settings = {
      check_updates = false;
    };
  };
}
