{ mkHyprlandModule, ... }:
{ pkgs-unstable, ... }:
mkHyprlandModule {
  home.packages = [ pkgs-unstable.wl-clipboard ]; # Wayland clipboard utilities

  services.cliphist = {
    enable = true;
    package = pkgs-unstable.cliphist;
  };
}
