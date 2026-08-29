{ mkDefaultHyprlandModule, ... }:
mkDefaultHyprlandModule { dir = ./.; } {
  programs.yas.enable = true;
}
