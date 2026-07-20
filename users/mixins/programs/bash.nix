{ mkMixinModule, ... }:
mkMixinModule "bash" {
  programs.bash = {
    enable = true;

    shellAliases = {
      ls = "ls --color=auto --human-readable";
      ll = "ls --color=auto --human-readable -l --group-directories-first";
      la = "ls --color=auto --human-readable -l --group-directories-first --all";
      grep = "grep --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };
}
