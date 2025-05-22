{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  cfg = config.programs.gnome-shell;
  iconsOpts = {
    options = {
      name = mkOption {
        type = types.str;
        example = "Dracula";
        description = ''
          Name of the icon pack.
        '';
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = lib.literalExpression "pkgs.dracula-icon-theme";
        description = ''
          Package providing a icon pack in
          `$out/share/icons/''${name}`.
        '';
      };
    };
  };
in {
  options.programs.gnome-shell = {
    icons = mkOption {
      type = types.nullOr (types.submodule iconsOpts);
      default = null;
      example = lib.literalExpression ''
        {
          name = "Dracula";
          package = pkgs.dracula-icon-theme;
        }
      '';
      description = ''
        Icons to use for GNOME Shell.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.icons != null) {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        icon-theme = cfg.icons.name;
      };
    };

    home.packages = [cfg.icons.package];
  };
}
