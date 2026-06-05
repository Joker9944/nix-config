{ mkDefaultHyprlandModule, ... }:
mkDefaultHyprlandModule { dir = ./.; } {
  wayland.windowManager.hyprland.configType = "lua";
}
