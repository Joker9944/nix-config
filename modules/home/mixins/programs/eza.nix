{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "eza" {
  programs.eza = {
    enable = true;
    git = config.programs.git.enable;
    icons = "auto";
    # upstream's mkDefault aliases become fish abbrs under preferAbbrs and shadow ours
    enableFishIntegration = false;
  };

  home.shellAliases = {
    ls = "eza";
    la = "eza --all";
    ll = "eza --long --group-directories-first";
    lla = "eza --all --long --group-directories-first";
    lt = "eza --tree";
    lta = "eza --all --tree";
  };
}
