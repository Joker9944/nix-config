{ mkDefaultHyprlandModule, ... }:
mkDefaultHyprlandModule { dir = ./.; } {
  programs = {
    waybar.enable = false;
    ashell.enable = false;
    yab.enable = true;
  };
}
