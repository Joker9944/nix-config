{ mkThemeModule, ... }:
{ pkgs, ... }:
mkThemeModule "uwunicorn" {
  custom.theme = {
    # The palette slot `gtk.accent` selects, named directly now that it no longer doubles
    # as the accent selector.
    accent = "base0E";

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
