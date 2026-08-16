{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "regreet" {
  programs.regreet = {
    enable = true;

    font = config.custom.theme.fonts.interface;

    iconTheme = config.custom.theme.icons;
    cursorTheme = config.custom.theme.cursor;

    settings.GTK.application_prefer_dark_theme = true;
  };

  schemes.regreet.enable = true;
}
