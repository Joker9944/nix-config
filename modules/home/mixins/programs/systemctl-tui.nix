{ mkMixinModule, ... }:
mkMixinModule "systemctl-tui" {
  home.shellAbbrs.st = "systemctl-tui";

  programs.systemctl-tui.enable = true;
}
