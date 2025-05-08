{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.services.xserver.desktopManager.gnome.enable {
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-connections
      epiphany # web browser
    ];

    environment.systemPackages = with pkgs; [
      gnomeExtensions.tophat
      libgtop # Dependency for TopHat
      clutter # Dependency for TopHat
      gnomeExtensions.clipboard-history
      gnomeExtensions.auto-move-windows
      gnomeExtensions.dash-to-dock
      dconf-editor
      gparted
    ];

    environment.variables = {
      # TODO Workaround for missing TopHat dependency
      # https://github.com/fflewddur/tophat/issues/106#issuecomment-1848319826
      GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
    };
  };
}
