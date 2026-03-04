{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.mixins.displayManager =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "displayManager config mixin";
    };

  config =
    let
      cfg = config.mixins.displayManager;
    in
    lib.mkIf cfg.enable {
      programs.regreet = {
        enable = true;

        font = {
          name = "Inter";
          package = pkgs.inter;
          size = 10;
        };

        theme = {
          name = "Dracula";
          package = pkgs.dracula-theme;
        };

        iconTheme = {
          name = "Dracula";
          package = pkgs.dracula-icon-theme;
        };

        cursorTheme = {
          name = "Dracula-cursors";
          package = pkgs.dracula-theme;
        };

        settings = {
          application_prefer_dark_theme = true;
        };
      };
    };
}
