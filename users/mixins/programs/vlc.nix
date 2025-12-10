{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.vlc =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "vlc config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.vlc;
      package = pkgs.vlc;
    in
    lib.mkIf cfg.enable {
      home.packages = lib.toList package;

      xdg.mimeApps.custom.apps.default = lib.mkOrder 20 [
        "${package}/share/applications/vlc.desktop"
      ];
    };
}
