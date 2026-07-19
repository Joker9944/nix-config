{ mkHyprlandModule, ... }:
{ pkgs-unstable, ... }:
mkHyprlandModule {
  home.packages = [ pkgs-unstable.udiskie ];

  services = {
    udiskie = {
      enable = true;
      package = pkgs-unstable.udiskie;

      tray = "never";
    };
  };
}
