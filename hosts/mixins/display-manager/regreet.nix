{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "regreet" {
  programs.regreet = {
    enable = true;

    font = config.custom.theme.fonts.interface;

    iconTheme = { inherit (config.schemes.icons) name package; };
    cursorTheme = config.custom.theme.cursor;

    settings.GTK.application_prefer_dark_theme = true;
  };

  schemes.regreet.enable = true;
}
