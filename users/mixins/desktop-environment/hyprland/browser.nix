{
  lib,
  config,
  custom,
  ...
}:
let
  inherit (cfg.binds) mods;
  cfg = config.windowManager.hyprland.custom;
  bin.browser = lib.getExe config.programs.firefox.package;
in
custom.lib.mkHyprlandModule config {
  wayland.windowManager.hyprland.settings.bind = [ "${mods.main}, B, exec, ${bin.browser}" ];
}
