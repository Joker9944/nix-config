{ mkDefaultHyprlandModule, ... }:
{
  inputs,
  lib,
  config,
  options,
  pkgs,
  pkgs-unstable,
  custom,
  ...
}:
mkDefaultHyprlandModule { dir = ./.; } {
  imports = with inputs.nix-schemes.homeModules; [
    scheme
    gtk
    librewolf
  ];

  options.mixins.desktopEnvironment.hyprland.style =
    let
      inherit (lib) mkOption types;
    in
    {
      theme = mkOption {
        type = types.enum [
          "dracula"
          "uwunicorn"
        ];
        default = "uwunicorn";
        description = ''
          The theme to style hyprland and apps with.
        '';
      };

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

      scheme = mkOption {
        type = types.nullOr types.attrs;
        description = ''
          Color scheme that can be reference.
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

  config =
    let
      cfg = config.mixins.desktopEnvironment.hyprland.style;
    in
    {
      home.packages = lib.flatten [
        (lib.optional (
          cfg.fonts.interface != null && cfg.fonts.interface.package != null
        ) cfg.fonts.interface.package)
        (lib.optional (
          cfg.fonts.terminal != null && cfg.fonts.terminal.package != null
        ) cfg.fonts.terminal.package)
        (lib.optional (cfg.xCursor != null && cfg.xCursor.package != null) cfg.xCursor.package)
        (lib.optional (cfg.icons != null && cfg.icons.package != null) cfg.icons.package)
      ];

      mixins.desktopEnvironment.hyprland.style = {
        fonts = {
          interface = {
            name = "Inter";
            package = pkgs.inter;
            size = 10;
          };

          terminal = {
            name = "JetBrainsMono Nerd Font Mono";
            package = pkgs.nerd-fonts.jetbrains-mono;
            size = 10;
          };
        };

        inherit (config.schemes) scheme;

        opacity = {
          active = 0.95;
          inactive = 0.9;
        };

        border = {
          size = 2;

          corners = {
            rounding = 10;
            power = 2.0;
          };
        };
      };

      custom.easyGtk = {
        enable = lib.mkDefault true;

        documentText = {
          name = "Lato";
          package = pkgs.lato;
          size = 12;
        };

        monospaceText = {
          name = "JetBrains Mono";
          package = pkgs.jetbrains-mono;
          size = 10;
        };

        interfaceText = lib.mkDefault cfg.fonts.interface;
        cursorTheme = lib.mkDefault cfg.xCursor;
        iconTheme = lib.mkDefault cfg.icons;

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
          profiles = [ custom.config.username ];
        };
      };
    };
}
