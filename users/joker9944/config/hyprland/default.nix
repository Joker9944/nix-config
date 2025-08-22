/**
  Hyprland meta module

  TODO config
   - waybar
   - yazi
   - wofi
   - hyprlock
   - hyprpaper
   - hypridle

  TODO Setup
   - Investigate hyprpolkitagent
   - There are a lot of styling utils take a look once theming
   - hyprsunset with release-25.11
*/
{
  lib,
  config,
  pkgs,
  utility,
  custom,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
in
utility.custom.mkHyprlandModule config {
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  # Common options shared by all hyprland modules
  # TODO export default somewhere
  options.desktopEnvironment.hyprland = with lib; {
    enable = lib.mkEnableOption "Hyprland desktop environment config";

    bind = {
      mods =
        let
          mkBindModsOption =
            name: defaultMod:
            mkOption {
              type = types.str;
              default = defaultMod;
              description = ''
                Bind mod used for ${name}
              '';
            };
        in
        {
          main = mkBindModsOption "main" "SUPER";
          workspace = mkBindModsOption "workspace" "SUPER SHIFT";
          utility = mkBindModsOption "utility" "SUPER CTRL";
          app = mkBindModsOption "app" "SUPER ALT";
        };
    };

    terminal = {
      mkTuiCommand = mkOption {
        type = types.functionTo types.str;
        description = ''
          Function used to generate exec command for TUI app binds.
        '';
      };

      mkWindowRules = mkOption {
        type = types.functionTo (types.listOf types.str);
        description = ''
          Function used to generate window rules for terminal windows.
        '';
      };
    };

    launcher = {
      mkDmenuCommand = mkOption {
        type = types.functionTo types.str;
        description = ''
          Function used to generate a dmenu like command.
        '';
      };
    };

    steam = {
      appRegex = mkOption {
        type = types.str;
        default = "steam_app_.+";
        description = ''
          Regex used to recognize steam apps.
        '';
      };
    };

    style = {
      font = {
        name = mkOption {
          type = types.str;
          default = "Inter";
          description = ''
            Font name used for interface text.
          '';
        };

        package = mkPackageOption pkgs "inter" { };
        size = mkOption {
          type = types.int;
          default = 10;
          description = ''
            Font size used for interface text.
          '';
        };
      };

      iconTheme = {
        name = mkOption {
          type = types.str;
          default = "Dracula";
          description = ''
            Main icon theme used.
          '';
        };
        package = mkPackageOption pkgs "dracula-icon-theme" { };
      };

      pallet = mkOption {
        type = types.attrs;
        default = custom.assets.palettes.dracula;
      };

      opacity = {
        active = mkOption {
          type = types.float;
          default = 0.95;
        };

        inactive = mkOption {
          type = types.float;
          default = 0.9;
        };
      };

      border = {
        size = mkOption {
          type = types.int;
          default = 2;
        };

        corners = {
          rounding = mkOption {
            type = types.int;
            default = 10;
          };

          power = mkOption {
            type = types.float;
            default = 2.0;
          };
        };
      };
    };
  };

  config = {
    home.packages = [
      cfg.style.font.package
      cfg.style.iconTheme.package
    ];
  };
}
