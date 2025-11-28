{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.windowManager.hyprland.custom.gnome-compat;
in
{
  options.windowManager.hyprland.custom.gnome-compat = with lib; {
    inherit (options.gnome-settings.appearance) style accentColor;
    inherit (options.gnome-tweaks.fonts) documentText;
    inherit (options.gtk) theme;
    enable = mkEnableOption "compatibility config for GTK and GNOME apps";

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

  config = lib.mkIf cfg.enable {
    gtk = {
      inherit (cfg) theme cursorTheme iconTheme;
      enable = true;
    };

    gnome-settings.appearance = {
      inherit (cfg) style accentColor;
      enable = true;
    };

    gnome-tweaks.fonts = {
      inherit (cfg) interfaceText documentText monospaceText;
      enable = true;
    };
  };
}
