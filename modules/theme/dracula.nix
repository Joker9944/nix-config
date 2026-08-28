{ mkThemeModule, ... }:
{ pkgs, ... }:
mkThemeModule "dracula" {
  custom.theme = {
    accent = "#815CD6";

    gtk = {
      accent = "purple";
      uniformAccents = true;
    };
  };

  schemes = {
    source.tinted = {
      system = "base24";
      slug = "dracula";
    };

    # Dracula ships an ANSI black distinct from its background; the scheme parks it in
    # base01, where the spec puts base00.
    overrides.ansi."0" = "base01";

    icons = {
      name = "Dracula";
      base = pkgs.dracula-icon-theme;
    };
  };
}
