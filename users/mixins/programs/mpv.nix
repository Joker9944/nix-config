{ lib, config, ... }:
{
  options.mixins.programs.mpv =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "mpv config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.mpv;
    in
    lib.mkIf cfg.enable {
      programs.mpv = {
        enable = true;
      };

      xdg.mimeApps.custom.apps.default = lib.mkOrder 10 [
        "${config.programs.mpv.package}/share/applications/umpv.desktop" # cSpell:ignore umpv
      ];
    };
}
