{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-unstable,
  ...
}:
mkHyprlandModule {
  options.mixins.desktopEnvironment.hyprland.style =
    let
      inherit (lib) mkOption types;
    in
    {
      opacity = {
        active = mkOption {
          type = types.float;
          default = 0.95;
          description = ''
            Opacity for active widgets.
          '';
        };

        inactive = mkOption {
          type = types.float;
          default = 0.9;
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
    };

  config =
    let
      theme = config.custom.theme;
    in
    {
      home.packages =
        lib.optional (theme.fonts.interface.package != null) theme.fonts.interface.package
        ++ lib.optional (theme.fonts.terminal.package != null) theme.fonts.terminal.package
        ++ [
          config.schemes.cursors.package
          config.schemes.icons.package
        ];

      custom.easyGtk = {
        enable = lib.mkDefault true;

        interfaceText = lib.mkDefault theme.fonts.interface;
        documentText = lib.mkDefault theme.fonts.document;
        monospaceText = lib.mkDefault theme.fonts.monospace;

        cursorTheme = lib.mkDefault { inherit (config.schemes.cursors) name package; };
        iconTheme = lib.mkDefault { inherit (config.schemes.icons) name package; };

        qtCompat = {
          qt5DecorationsPackage = pkgs-unstable.qadwaitadecorations;
          qt6DecorationsPackage = pkgs-unstable.qadwaitadecorations-qt6;
        };

        xdgDesktopPortalGtkPackage = pkgs-unstable.xdg-desktop-portal-gtk;
      };

      schemes = {
        gtk.enable = true;

        librewolf = {
          enable = true;
          # TODO this is not right, find a way to improve this
          profiles = [ config.home.username ];
        };
      };
    };
}
