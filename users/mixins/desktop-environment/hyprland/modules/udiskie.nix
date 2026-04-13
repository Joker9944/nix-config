{ mkHyprlandModule, ... }:
{ pkgs-hyprland, ... }:
mkHyprlandModule {
  home.packages = [ pkgs-hyprland.udiskie ];

  services = {
    udiskie = {
      enable = true;
      package = pkgs-hyprland.udiskie;

      tray = "never";
    };
  };
}
