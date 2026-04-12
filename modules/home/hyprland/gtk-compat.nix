_:
{
  lib,
  config,
  options,
  pkgs,
  ...
}:
{
  options.windowManager.hyprland.custom.gtkCompat =
    let
      inherit (lib) mkEnableOption mkPackageOption;
    in
    {
      inherit (options.gnome-settings.appearance) style accentColor;
      inherit (options.gnome-tweaks.fonts) documentText;
      inherit (options.gnome-misc.qtCompat) qt5DecorationsPackage qt6DecorationsPackage;
      inherit (options.gtk) theme;

      enable = mkEnableOption "compatibility config for GTK and GNOME apps";

      qtCompat = (mkEnableOption "compatibility for gtk to qt") // {
        default = true;
      };

      interfaceText = options.gnome-tweaks.fonts.interfaceText // {
        default = config.windowManager.hyprland.custom.style.fonts.interface;
      };

      monospaceText = options.gnome-tweaks.fonts.monospaceText // {
        default = config.windowManager.hyprland.custom.style.fonts.terminal;
      };

      cursorTheme = options.gtk.cursorTheme // {
        default = config.windowManager.hyprland.custom.style.xCursor;
      };

      iconTheme = options.gtk.iconTheme // {
        default = config.windowManager.hyprland.custom.style.icons;
      };

      xdgDesktopPortalGtkPackage = mkPackageOption pkgs "xdg-desktop-portal-gtk" { };
    };

  config =
    let
      cfg = config.windowManager.hyprland.custom.gtkCompat;
    in
    lib.mkIf cfg.enable {
      gtk = {
        enable = lib.mkDefault true;

        theme = lib.mkIf (cfg.theme != null) cfg.theme;
        cursorTheme = lib.mkIf (cfg.cursorTheme != null) cfg.cursorTheme;
        iconTheme = lib.mkIf (cfg.iconTheme != null) cfg.iconTheme;
      };

      gnome-misc.qtCompat = {
        enable = lib.mkDefault true;

        inherit (cfg) qt5DecorationsPackage qt6DecorationsPackage;
      };

      gnome-settings.appearance = {
        enable = lib.mkDefault true;

        inherit (cfg) style accentColor;
      };

      gnome-tweaks.fonts = {
        enable = lib.mkDefault true;

        inherit (cfg) interfaceText documentText monospaceText;
      };

      xdg.portal = {
        enable = lib.mkDefault true;

        extraPortals = [ cfg.xdgDesktopPortalGtkPackage ];
      };
    };
}
