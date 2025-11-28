{
  lib,
  config,
  options,
  ...
}:
{
  options.windowManager.hyprland.custom.style =
    let
      inherit (lib) mkOption types;
    in
    {
      fonts = {
        interface = mkOption {
          type = types.nullOr lib.hm.types.fontType;
          default = null;
          description = ''
            Preferred interface text font for reference.
          '';
        };

        terminal = mkOption {
          type = types.nullOr lib.hm.types.fontType;
          default = null;
          description = ''
            Preferred terminal text font for reference.
          '';
        };
      };

      pallet = mkOption {
        type = types.nullOr types.attrs;
        description = ''
          Color pallet that can be reference.
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

  config.home.packages =
    let
      cfg = config.windowManager.hyprland.custom.style;
    in
    lib.flatten [
      (lib.optional (
        cfg.fonts.interface != null && cfg.fonts.interface.package != null
      ) cfg.fonts.interface.package)
      (lib.optional (
        cfg.fonts.terminal != null && cfg.fonts.terminal.package != null
      ) cfg.fonts.terminal.package)
      (lib.optional (cfg.xCursor != null && cfg.xCursor.package != null) cfg.xCursor.package)
      (lib.optional (cfg.icons != null && cfg.icons.package != null) cfg.icons.package)
    ];
}
