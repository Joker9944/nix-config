{ lib, config, ... }:
{
  options.mixins.programs.gnome-text-editor =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "gnome-text-editor config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.gnome-text-editor;
    in
    lib.mkIf cfg.enable {
      programs.gnome-text-editor = {
        enable = true;
      };

      xdg.mimeApps.custom.apps.default = [
        "${config.programs.gnome-text-editor.package}/share/applications/org.gnome.TextEditor.desktop"
      ];
    };
}
