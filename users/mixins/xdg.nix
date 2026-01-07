{ lib, config, ... }:
{
  options.mixins.xdg =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "xdg config mixin";
    };

  config =
    let
      cfg = config.mixins.xdg;
    in
    lib.mkIf cfg.enable {
      xdg = {
        autostart.enable = true;
        mimeApps.enable = true;
      };
    };
}
