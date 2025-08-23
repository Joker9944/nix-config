/**
  * screenshot utility
*/
{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  inherit (config.desktopEnvironment.hyprland.bind) mods;
  bin.hyprshot = "${config.programs.hyprshot.package}/bin/hyprshot";
in
utility.custom.mkHyprlandModule config {
  programs.hyprshot = {
    enable = true;
    package = pkgs-hyprland.hyprshot;

    saveLocation = "$HOME/Pictures/Screenshots";
  };

  wayland.windowManager.hyprland.settings.bind = [
    ", PRINT, exec, ${bin.hyprshot} --mode region"
    "${mods.main}, PRINT, exec, ${bin.hyprshot} --mode active"
    "${mods.utility}, PRINT, exec, ${bin.hyprshot} --mode output"
  ];
}
