{ mkMixinModule, ... }:
{
  inputs,
  pkgs,
  ...
}:
mkMixinModule "tmux" {
  imports = [ inputs.tmux-which-key.homeManagerModules.default ];

  config = {
    programs.tmux = {
      enable = true;

      keyMode = "vi";
      baseIndex = 1;
      clock24 = true;
      mouse = true;
      focusEvents = true;
      historyLimit = 50000;
      terminal = "tmux-256color";

      sensibleOnTop = true;

      plugins = with pkgs.tmuxPlugins; [
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10'
          '';
        }
        yank
        vim-tmux-navigator
      ];

      tmux-which-key = {
        enable = true;
        settings = import ./tmux-which-key-config.nix;
      };
    };
  };
}
