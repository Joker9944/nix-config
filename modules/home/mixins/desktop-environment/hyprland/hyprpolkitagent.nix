{ mkHyprlandModule, ... }:
{ pkgs-unstable, ... }:
mkHyprlandModule {
  services.hyprpolkitagent = {
    enable = true;
    package = pkgs-unstable.hyprpolkitagent;
  };
}
