{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.common.desktopEnvironment.kde-plasma;

  colors = {
    # Japanese violet - https://encycolorpedia.com/5b3256
    accentPrimaryColor = "235,89,61"; # Orange soda - https://encycolorpedia.com/eb593d
    accentSecondaryColor = "41,204,255";
  };

  workspaces = [
    "Default"
    "Social"
    "Coding"
    "Media"
  ];
  workspaceIndex = name: (lib.lists.findFirstIndex (workspace: workspace == name) 0 workspaces) + 1;
  workspaceInternalName = name: "Desktop_" + (builtins.toString (workspaceIndex name));
in {
  options.common.desktopEnvironment.kde-plasma = with lib; {
    enable = mkEnableOption "Whether to enable KDE Plasma desktop environment config.";
  };

  config = lib.mkIf cfg.enable {
    programs.plasma = {
      enable = true;

      overrideConfig = true;
      immutableByDefault = true;

      # Theming
      workspace.lookAndFeel = "org.kde.breezedark.desktop";
      configFile."kdeglobals"."General"."AccentColor" = colors.accentPrimaryColor;

      # Shortcuts
      shortcuts = {
        "ksmserver"."Lock Session" = ["Meta+Esc" "Meta+L" "Screensaver"];
        "services/org.kde.plasma-systemmonitor.desktop"."_launch" = [];
        "kwin" = {
          "Overview" = ["Meta" "Meta+D"]; # Mission Control
          "Window One Desktop Up" = ["Meta+Shift+Up"];
          "Window One Desktop to the Right" = ["Meta+Shift+Right"];
          "Window One Desktop Down" = ["Meta+Shift+Down"];
          "Window One Desktop to the Left" = ["Meta+Shift+Left"];
          "Window to Next Screen" = [];
          "Window to Previous Screen" = [];
          "Edit Tiles" = [];
          "Show Desktop" = [];
        };
        "plasmashell"."activate application launcher" = ["Meta+A" "Alt+F1"];
      };
      hotkeys.commands = {
        "launch-konsole" = {
          name = "Launch Konsole";
          key = "Meta+T";
          command = "konsole";
        };

        "launch-btop" = {
          name = "Launch btop++";
          key = "Ctrl+Shift+Esc";
          command = "btop";
        };
      };

      # Panels
      panels = [
        {
          location = "top";
          screen = "all";
          height = 36;
          widgets = [
            {
              # Application Launcher
              kickerdash = {
                icon = "nix-snowflake";
              };
            }
            {
              panelSpacer = {};
            }
            {
              digitalClock = {};
            }
            "org.kde.plasma.notifications"
            {
              panelSpacer = {};
            }
            {
              # CPU Chart
              systemMonitor = {
                title = "Individual Core Usage";
                displayStyle = "org.kde.ksysguard.barchart";
                totalSensors = ["cpu/all/usage"];
                sensors = lib.lists.genList (i: {
                  name = "cpu/cpu" + (builtins.toString i) + "/usage";
                  color = colors.accentPrimaryColor;
                  label = "Core " + (builtins.toString i);
                })
                24;
              };
            }
            {
              # Memory Chart
              systemMonitor = {
                title = "Memory Usage";
                displayStyle = "org.kde.ksysguard.piechart";
                totalSensors = ["memory/physical/usedPercent"];
                textOnlySensors = ["memory/physical/total"];
                sensors = [
                  {
                    name = "memory/physical/used";
                    color = colors.accentPrimaryColor;
                    label = "Used Physical Memory";
                  }
                ];
              };
            }
            {
              # Swap Chart
              systemMonitor = {
                title = "Swap Usage";
                displayStyle = "org.kde.ksysguard.piechart";
                totalSensors = ["memory/swap/usedPercent"];
                textOnlySensors = ["memory/swap/total"];
                sensors = [
                  {
                    name = "memory/swap/used";
                    color = colors.accentPrimaryColor;
                    label = "Used Swap Memory";
                  }
                ];
              };
            }
            {
              # Network Chart
              systemMonitor = {
                title = "Network Speed";
                displayStyle = "org.kde.ksysguard.linechart";
                sensors = [
                  {
                    name = "network/all/download";
                    color = colors.accentPrimaryColor;
                    label = "Download Rate";
                  }
                  {
                    name = "network/all/upload";
                    color = colors.accentSecondaryColor;
                    label = "Upload Rate";
                  }
                ];
              };
            }
            {
              # System Tray
              systemTray = {
                items = {
                  showAll = true;
                  hidden = [
                    ""
                  ];
                };
              };
            }
          ];
        }
      ];

      # Program grouping
      kwin.virtualDesktops = {
        rows = 1;
        names = workspaces;
      };

      window-rules =
        lib.mapAttrsToList (name: value: {
          description = name;
          match.window-class.value = value.windowClass;
          apply = {
            desktops = {
              value = workspaceInternalName value.workspace;
              apply = "force";
            };
          };
        }) {
          "Steam" = {
            windowClass = "steamwebhelper steam";
            workspace = "Default";
          };
          "Telegram" = {
            windowClass = "telegram-desktop org.telegram.desktop";
            workspace = "Social";
          };
          "Discord" = {
            windowClass = "discord discord";
            workspace = "Social";
          };
          "Visual Studio Code" = {
            windowClass = "code Code";
            workspace = "Coding";
          };
          "Spotify" = {
            windowClass = "spotify Spotify";
            workspace = "Media";
          };
        };
    };
  };
}
