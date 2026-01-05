{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.desktopEnvironment.gnome =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "GNOME desktop environment config mixin";
    };

  config =
    let
      cfg = config.mixins.desktopEnvironment.gnome;

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
    lib.mkIf cfg.enable {
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

        keyboard.shortcuts = {
          enable = true;

          customShortcuts = [
            {
              name = "Launch Console";
              command = "kgx";
              binding = "<Super>t";
            }
            {
              name = "Launch btop++";
              command = "kgx -- btop";
              binding = "<Shift><Control>Escape";
            }
          ];
        };
      };

      gnome-tweaks = {
        fonts = {
          enable = true;

          interfaceText = {
            name = "Inter";
            package = pkgs.inter;
            size = 10;
          };

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

        # Keybindings
        "org/gnome/desktop/wm/keybindings" = {
          move-to-monitor-up = mkEmptyArray type.string;
          move-to-monitor-down = mkEmptyArray type.string;
          move-to-monitor-left = mkEmptyArray type.string;
          move-to-monitor-right = mkEmptyArray type.string;
          move-to-workspace-left = [ "<Shift><Super>Left" ];
          move-to-workspace-right = [ "<Shift><Super>Right" ];
          switch-to-workspace-left = [ "<Control><Super>Left" ];
          switch-to-workspace-right = [ "<Control><Super>Right" ];
          maximize = [ "<Super>Page_Up" ];
          unmaximize = [ "<Super>Page_Down" ]; # cSpell:words unmaximize
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          home = [ "<Super>e" ];
          calculator = [ "<Super>c" ];
          screensaver = [
            "<Super>Escape"
            "<Super>l"
          ];
        };
        "org/gnome/mutter/wayland/keybindings" = {
          restore-shortcuts = mkEmptyArray type.string;
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
