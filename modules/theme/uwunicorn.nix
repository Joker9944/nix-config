{ mkThemeModule, ... }:
{ pkgs, ... }:
mkThemeModule "uwunicorn" {
  custom.theme = {
    accent = "base0E"; # magenta normal

    gtk.accent = "purple";
  };

  schemes = {
    source.tinted = {
      system = "base16";
      slug = "uwunicorn";
    };

    icons = {
      name = "Colloid-Dark";
      base = pkgs.colloid-icon-theme;
    };
  };
}
