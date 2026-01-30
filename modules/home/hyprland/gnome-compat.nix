{
  lib,
  config,
  options,
  pkgs-hyprland,
  ...
}:
{
  options.windowManager.hyprland.custom.gnomeCompat =
    let
      inherit (lib) mkEnableOption;
    in
    {
      inherit (options.gnome-settings.appearance) style accentColor;
      inherit (options.gnome-tweaks.fonts) documentText;
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
    };

  config =
    let
      cfg = config.windowManager.hyprland.custom.gnomeCompat;
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
        qAdwaitaDecorationsPackages = {
          qt5 = pkgs-hyprland.qadwaitadecorations;
          qt6 = pkgs-hyprland.qadwaitadecorations-qt6;
        };
      };

      gnome-settings.appearance = {
        inherit (cfg) style accentColor;
        enable = true;
      };

      gnome-tweaks.fonts = {
        inherit (cfg) interfaceText documentText monospaceText;
        enable = true;
      };

      xdg.portal = {
        enable = lib.mkDefault true;
        extraPortals = [ pkgs-hyprland.xdg-desktop-portal-gtk ];
      };
    };
}
