{ lib, config, ... }:
{
  options.mixins.programs.papers =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "papers config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.papers;
    in
    lib.mkIf cfg.enable {
      programs.papers = {
        enable = true;
      };

      xdg.mimeApps.custom.apps.default = lib.mkOrder 20 [
        "${config.programs.papers.package}/share/applications/org.gnome.Papers.desktop"
      ];
    };
}
