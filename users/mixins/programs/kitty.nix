{ mkMixinModule, ... }:
_:
mkMixinModule "kitty" {
  programs.kitty = {
    enable = true;

    enableGitIntegration = true;

    keybindings."ctrl+shift+t" = "new_tab_with_cwd";
  };
}
