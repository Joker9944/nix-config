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
  pkgs,
  config,
  utility,
  custom,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
in
{
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  options.desktopEnvironment.hyprland = with lib; {
    enable = mkEnableOption "Hyprland desktop environment config";
  };

  config = lib.mkIf cfg.enable {
    windowManager.hyprland.custom = {
      enable = true;

      binds.mods = {
        main = "SUPER";
        workspace = "SUPER SHIFT";
        utility = "SUPER CTRL";
        app = "SUPER ALT";
      };

      style = {
        font = {
          name = "Inter";
          package = pkgs.inter;
          size = 10;
        };

        pallet = custom.assets.palettes.dracula;

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

        xCursor = {
          name = "Dracula-cursors";
          package = pkgs.dracula-theme;
        };

        icons = {
          name = "Dracula";
          package = pkgs.dracula-icon-theme;
        };
      };

      gnome-compat = {
        enable = true;

        style = "prefer-dark";
        accentColor = "purple";

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

        theme = {
          name = "Dracula";
          package = pkgs.dracula-theme;
        };
      };
    };
  };
}
