{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.windowManager.hyprland.custom.style;
in
{
  options.windowManager.hyprland.custom.style = with lib; {
    font = mkOption {
      type = types.nullOr lib.hm.types.fontType;
      default = null;
      description = ''
        Preferred interface text font for referenced.
      '';
    };

    pallet = mkOption {
      type = types.nullOr types.attrs;
      description = ''
        Color pallet that can be referenced.
      '';
    };

    opacity = {
      active = mkOption {
        type = types.float;
        default = 1.0;
        description = ''
          Opacity for active widgets.
        '';
      };

      inactive = mkOption {
        type = types.float;
        default = 1.0;
        description = ''
          Opacity for inactive widgets.
        '';
      };
    };

    border = {
      size = mkOption {
        type = types.int;
        default = 2;
        description = ''
          Border size in pixels.
        '';
      };

      corners = {
        rounding = mkOption {
          type = types.int;
          default = 10;
          description = ''
            Corner rounding size in pixels.
          '';
        };

        power = mkOption {
          type = types.float;
          default = 2.0;
          description = ''
            Rounding power for corner rounding.
          '';
        };
      };
    };

    xCursor = options.gtk.cursorTheme // {
      description = ''
        xCursor for reference.
      '';
    };

    icons = options.gtk.iconTheme // {
      description = ''
        Icon pack for reference.
      '';
    };
  };

  config = {
    home.packages =
      lib.optional (cfg.font != null && cfg.font.package != null) cfg.font.package
      ++ lib.optional (cfg.xCursor != null && cfg.xCursor.package != null) cfg.xCursor.package
      ++ lib.optional (cfg.icons != null && cfg.icons.package != null) cfg.icons.package;
  };
}
