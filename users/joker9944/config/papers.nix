{ lib, config, ... }:
{
  programs.papers = {
    enable = true;
  };

  xdg.mimeApps.custom.apps.default = lib.mkOrder 20 [
    "${config.programs.papers.package}/share/applications/org.gnome.Papers.desktop"
  ];
}
