/**
TODO config
- waybar
- yazi
- wofi
- hyprlock
- hyprpaper
- hypridle

TODO Setup
 - maybe replace hyprlock with a login and lock screen
 - Investigate hyprpolkitagent
 - There are a lot of styling utils take a look once theming
 - Enable ly once saying goodbye to GNOME
 - hyprshot
*/
{
  lib,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  imports = (utility.custom.ls.lookup {
    dir = ./.;
    exclude = [./default.nix];
  });

  options.desktopEnvironment.hyprland.enable = lib.mkEnableOption "Hyprland desktop environment config";
}
