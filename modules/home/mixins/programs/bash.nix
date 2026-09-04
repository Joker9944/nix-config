{ mkMixinModule, ... }:
mkMixinModule "bash" {
  programs.bash = {
    enable = true;

    shellAliases = {
      grep = "grep --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };
}
