{ mkMixinModule, ... }:
mkMixinModule "zap" {
  programs.zap.enable = true;
}
