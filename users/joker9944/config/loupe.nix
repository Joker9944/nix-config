{ lib, config, ... }:
{
  programs.loupe = {
    enable = true;
  };

  xdg.mimeApps.custom.apps.default = lib.mkOrder 10 [
    "${config.programs.loupe.package}/share/applications/org.gnome.Loupe.desktop"
  ];
}
