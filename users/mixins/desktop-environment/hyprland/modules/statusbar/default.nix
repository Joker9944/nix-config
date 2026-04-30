{ mkDefaultHyprlandModule, ... }:
mkDefaultHyprlandModule { dir = ./.; } {
  programs = {
    waybar.enable = false;
    ashell.enable = false;
    yas.enable = true;
  };
}
