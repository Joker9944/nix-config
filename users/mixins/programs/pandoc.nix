{ mkMixinModule, ... }:
{ lib, pkgs, ... }:
mkMixinModule "pandoc" {
  home.packages = [ pkgs.texliveFull ];

  programs.pandoc = {
    enable = true;

    defaults = {
      pdf-engine = "xelatex";
    };

    templates = lib.fix (self: {
      "default.latex" = self."eisvogel.latex";
      "eisvogel.latex" = "${pkgs.eisvogel}/share/eisvogel/templates/eisvogel.latex";
      "eisvogel.beamer" = "${pkgs.eisvogel}/share/eisvogel/templates/eisvogel.beamer";
    });
  };
}
