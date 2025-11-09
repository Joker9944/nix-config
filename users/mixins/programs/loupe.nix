{ lib, config, ... }:
{
  options.mixins.programs.loupe =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "loupe config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.loupe;
    in
    lib.mkIf cfg.enable {
      programs.loupe = {
        enable = true;
      };

      xdg.mimeApps.custom.apps.default = lib.mkOrder 10 [
        "${config.programs.loupe.package}/share/applications/org.gnome.Loupe.desktop"
      ];
    };
}
