{ mkMixinModule, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
mkMixinModule "gnome" {
  config =
    let

      mkAutoMoveWindowsApplicationList =
        attrs: lib.attrValues (lib.mapAttrs (app: index: app + ":" + toString index) attrs);

      mkGnomeShellExtensionsList = lib.lists.map (name: {
        id = name + "@gnome-shell-extensions.gcampax.github.com"; # cSpell:ignore gcampax
        package = pkgs.gnome-shell-extensions;
      });
      mkGeneralShellExtensionsList = lib.lists.map (pkg: {
        id = pkg.extensionUuid;
        package = pkg;
      });
    in
    {
      programs = {
        gnome-shell = {
          enable = true;

          extensions =
            with pkgs.gnomeExtensions;
            mkGnomeShellExtensionsList [
              "auto-move-windows"
              "places-menu"
              "apps-menu"
            ]
            ++ mkGeneralShellExtensionsList [
              tophat
              clipboard-history
              worksets
              caffeine
            ];

          theme = {
            name = "Dracula";
            package = pkgs.dracula-theme;
          };
        };

        firefox.enableGnomeExtensions = true;
        librewolf.enableGnomeExtensions = true;
      };

      gtk = {
        enable = true;

        theme = {
          name = "Dracula";
          package = pkgs.dracula-theme;
        };

        cursorTheme = {
          name = "Dracula-cursors";
          package = pkgs.dracula-theme;
        };

        iconTheme = {
          name = "Dracula";
          package = pkgs.dracula-icon-theme;
        };
      };

      gnome-settings = {
        multitasking = {
          enable = true;

          workspaces = "fixed";
          multiMonitor = "all-displays";
          appSwitching = "current-workspace";
        };

        appearance = {
          enable = true;

          style = "prefer-dark";
          accentColor = "purple";

          background = {
            picturePath = "/run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
            darkStylePicturePath = "/run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
            primaryColor = "#241f31";
          };
        };

        peripherals = {
          enable = true;

          mouse = {
            pointerSpeed = 0.5;
            mouseAcceleration = false;
          };
        };

      };

      gnome-tweaks = {
        fonts = {
          enable = true;

          interfaceText = config.custom.theme.fonts.interface;
          documentText = config.custom.theme.fonts.document;
          monospaceText = config.custom.theme.fonts.monospace;
        };
      };

      dconf.settings = with lib.hm.gvariant; {
        "org/gnome/shell/extensions/tophat" = {
          # Memory
          mem-display = "numeric";
          # Disk
          fs-display = "numeric";
          mount-to-monitor = "/";
          fs-hide-in-menu = "/boot";
          # Network
          network-usage-unit = "bits";
        };

        # Behavior
        "org/gnome/shell/extensions/auto-move-windows" = {
          application-list = mkAutoMoveWindowsApplicationList {
            "steam.desktop" = 1;
            "discord.desktop" = 2;
            "org.telegram.desktop.desktop" = 2;
            "code.desktop" = 3;
            "spotify.desktop" = 4;
          };
        };

        # Weather
        "org/gnome/GWeather4" = {
          temperature-unit = "centigrade";
        };
        "org/gnome/shell/weather" = {
          automatic-location = true;
        };
      };
    };
}
