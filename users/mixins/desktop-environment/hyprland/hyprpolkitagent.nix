{ mkHyprlandModule, ... }:
{ pkgs-hyprland, ... }:
mkHyprlandModule {
  services.hyprpolkitagent = {
    enable = true;
    package = pkgs-hyprland.hyprpolkitagent;
  };
}
