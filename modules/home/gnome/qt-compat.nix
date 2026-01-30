{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.gnome-misc.qtCompat =
    let
      inherit (lib) mkEnableOption mkPackageOption;
    in
    {
      enable = mkEnableOption "qt compatibility for a uniform application look";

      qAdwaitaDecorationsPackages = {
        qt5 = mkPackageOption pkgs "qadwaitadecorations" { };
        qt6 = mkPackageOption pkgs "qadwaitadecorations-qt6" { };
      };
    };

  config =
    let
      cfg = config.gnome-misc.qtCompat;
    in
    lib.mkIf cfg.enable {
      home = {
        packages = lib.attrValues cfg.qAdwaitaDecorationsPackages;

        sessionVariables = {
          QT_QPA_PLATFORMTHEME = "gtk3";
          QT_WAYLAND_DECORATION = "adwaita";
        };
      };
    };
}
