{ lib, config, pkgs, ... }:

{
  services.xserver = {
    enable = true;

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    epiphany # web browser
    gnome.geary # email reader. Up to 24.05. Starting from 24.11 the package name is just geary.
  ];

  environment.systemPackages = with pkgs; [
    gnomeExtensions.tophat
    libgtop # Dependency for TopHat
    clutter # Dependency for TopHat
    gnomeExtensions.clipboard-history
    gnomeExtensions.auto-move-windows
    gnomeExtensions.dash-to-dock
    gnomeExtensions.vertical-workspaces
    gnome.dconf-editor
  ];

  # TODO Workaround for missing TopHat dependency
  # https://github.com/fflewddur/tophat/issues/106#issuecomment-1848319826
  environment.variables = {
    GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
  };
}
