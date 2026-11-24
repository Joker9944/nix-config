{ mkMixinModule, ... }:
{ config, pkgs-unstable, ... }:
mkMixinModule "regreet" {
  programs.regreet = {
    enable = true;

    # UPGRADE(26.11): drop; 0.5.0 stops showing the unstyled window before init (rharish101/ReGreet#168).
    package = pkgs-unstable.regreet;

    font = config.custom.theme.fonts.interface;

    iconTheme = { inherit (config.schemes.icons) name package; };
    cursorTheme = { inherit (config.schemes.cursors) name package; };

    settings.GTK.application_prefer_dark_theme = true;
  };

  schemes.regreet.enable = true;
}
