{ mkMixinModule, ... }:
mkMixinModule "isd" {
  home.shellAliases.sc = "isd";

  programs.isd.enable = true;
}
