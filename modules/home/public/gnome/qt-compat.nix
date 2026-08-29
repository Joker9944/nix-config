_:
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

      qt5DecorationsPackage = mkPackageOption pkgs "qadwaitadecorations" { };
      qt6DecorationsPackage = mkPackageOption pkgs "qadwaitadecorations-qt6" { };
    };

  config =
    let
      cfg = config.gnome-misc.qtCompat;
    in
    lib.mkIf cfg.enable {
      home = {
        packages = [
          cfg.qt5DecorationsPackage
          cfg.qt6DecorationsPackage
        ];

        sessionVariables = {
          QT_QPA_PLATFORMTHEME = "gtk3";
          QT_WAYLAND_DECORATION = "adwaita";
        };
      };
    };
}
