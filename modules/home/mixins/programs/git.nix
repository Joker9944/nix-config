{ mkMixinModule, ... }:
mkMixinModule "git" {
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";
      fetch.prune = true;
      pull.rebase = false;
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
