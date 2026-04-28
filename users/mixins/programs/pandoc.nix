{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.pandoc =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "pandoc config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.pandoc;
    in
    lib.mkIf cfg.enable {
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
    };
}
