{ mkMixinModule, ... }:
mkMixinModule "direnv" {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables.DIRENV_WARN_TIMEOUT = "1m";
}
