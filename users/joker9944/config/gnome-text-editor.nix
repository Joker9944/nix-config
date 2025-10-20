{ config, ... }:
{
  programs.gnome-text-editor = {
    enable = true;
  };

  xdg.mimeApps.custom.apps.default = [
    "${config.programs.gnome-text-editor.package}/share/applications/org.gnome.TextEditor.desktop"
  ];
}
