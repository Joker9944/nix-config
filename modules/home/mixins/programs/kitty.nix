{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "kitty" {
  programs.kitty = {
    enable = true;

    enableGitIntegration = config.programs.git.enable;

    settings.enabled_layouts = "splits:split_axis=auto,stack";

    keybindings."ctrl+shift+d" = "new_window_with_cwd";
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };
}
