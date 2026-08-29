{ mkMixinModule, ... }:
mkMixinModule "systemctl-tui" {
  home.shellAliases.st = "systemctl-tui";

  programs.systemctl-tui.enable = true;
}
