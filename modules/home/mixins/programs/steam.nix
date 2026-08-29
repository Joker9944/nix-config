{ mkMixinModule, ... }:
mkMixinModule "steam" {
  programs.gamemode = {
    enable = true;
    package = null;
  };
}
