{ flake }:
{
  lib,
  config,
  options,
  pkgs,
  ...
}:
{
  options.custom.easyGtk =
    let
      inherit (lib) mkEnableOption mkPackageOption;
    in
    {
      enable = mkEnableOption "easy configuration for GTK";

      inherit (options.gtk) theme cursorTheme iconTheme;
      inherit (options.gnome-settings.appearance) style accentColor;
      inherit (options.gnome-tweaks.fonts) interfaceText monospaceText documentText;

      qtCompat = {
        enable = (mkEnableOption "qt adwaita decorations") // {
          default = true;
        };

        inherit (options.gnome-misc.qtCompat) qt5DecorationsPackage qt6DecorationsPackage;
      };

      xdgDesktopPortalGtkPackage = mkPackageOption pkgs "xdg-desktop-portal-gtk" {
        nullable = true;
      };
    };

  config =
    let
      cfg = config.custom.easyGtk;
    in
    lib.mkIf cfg.enable {
      gtk = {
        enable = lib.mkDefault true;

        theme = flake.lib.nonNull cfg.theme;
        cursorTheme = flake.lib.nonNull cfg.cursorTheme;
        iconTheme = flake.lib.nonNull cfg.iconTheme;
      };

      gnome-settings.appearance = {
        enable = lib.mkDefault true;

        style = flake.lib.nonNull cfg.style;
        accentColor = flake.lib.nonNull cfg.accentColor;
      };

      gnome-tweaks.fonts = {
        enable = lib.mkDefault true;

        interfaceText = flake.lib.nonNull cfg.interfaceText;
        documentText = flake.lib.nonNull cfg.documentText;
        monospaceText = flake.lib.nonNull cfg.monospaceText;
      };

      gnome-misc.qtCompat = lib.mkIf cfg.qtCompat.enable {
        enable = lib.mkDefault true;

        inherit (cfg.qtCompat) qt5DecorationsPackage qt6DecorationsPackage;
      };

      xdg.portal =
        lib.mkIf cfg.xdgDesktopPortalGtkPackage != null {
          enable = lib.mkDefault true;

          extraPortals = [ cfg.xdgDesktopPortalGtkPackage ];
        };
    };
}
