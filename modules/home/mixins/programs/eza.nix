{ mkMixinModule, ... }:
_:
mkMixinModule "eza" {
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };
}
