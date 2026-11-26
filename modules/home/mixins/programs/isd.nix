{ mkMixinModule, ... }:
mkMixinModule "isd" {
  home.shellAbbrs.sc = "isd";

  programs.isd.enable = true;
}
