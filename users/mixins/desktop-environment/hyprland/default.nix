/**
  Hyprland meta module

  TODO Setup
   - Investigate hyprpolkitagent
   - There are a lot of styling utils take a look once theming
*/
{
  inputs,
  lib,
  pkgs,
  config,
  custom,
  ...
}:
{
  imports =
    (custom.lib.ls {
      dir = ./.;
      exclude = [ ./default.nix ];
    })
    ++ [ inputs.nix-schemes.homeManagerModules.gtk ];

  options.mixins.desktopEnvironment.hyprland =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "Hyprland desktop environment config mixin";
    };

  config =
    let
      cfg = config.mixins.desktopEnvironment.hyprland;
    in
    lib.mkIf cfg.enable {
      windowManager.hyprland.custom = {
        enable = true;

        binds.mods = {
          main = "SUPER";
          workspace = "SUPER SHIFT";
          utility = "SUPER CTRL";
          app = "SUPER ALT";
        };

        style = {
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

          scheme = (inputs.nix-schemes.schemes.base24.dracula.convert pkgs).override (
            base: colorLib:
            let
              inherit (base) palette;
              mkColorFromHex = hex: colorLib.mkColor (colorLib.fromHex hex);
            in
            {
              custom.accent = config.schemes.gtk.accentColor;

              named = {
                # https://github.com/Base24/base24/blob/master/styling.md
                background = {
                  darker = palette.base11;
                  dark = palette.base10;
                  normal = palette.base00;
                  light = palette.base01;
                  lighter = palette.base02;
                };

                foreground = {
                  dark = palette.base04;
                  normal = palette.base05;
                  light = palette.base06;
                  lighter = palette.base07;
                };

                info = palette.base0D;
                warning = palette.base09;
                error = palette.base08;

                black = {
                  dull = palette.base00;
                  bright = palette.base02;
                };

                red = {
                  dull = palette.base08;
                  bright = palette.base12;
                };

                green = {
                  dull = palette.base0B;
                  bright = palette.base14;
                };

                yellow = {
                  dull = palette.base09;
                  bright = palette.base13;
                };

                magenta = {
                  dull = palette.base0E;
                  bright = palette.base17;
                };

                cyan = {
                  dull = palette.base0C;
                  bright = palette.base15;
                };

                white = {
                  dull = palette.base06;
                  bright = palette.base07;
                };
              };

              translations = {
                ansi = {
                  "0" = mkColorFromHex "#21222C";
                  "8" = mkColorFromHex "#6272A4";
                  "1" = mkColorFromHex "#FF5555";
                  "9" = mkColorFromHex "#FF6E6E";
                  "2" = mkColorFromHex "#50FA7B";
                  "A" = mkColorFromHex "#69FF94";
                  "3" = mkColorFromHex "#F1FA8C";
                  "B" = mkColorFromHex "#FFFFA5";
                  "4" = mkColorFromHex "#BD93F9";
                  "C" = mkColorFromHex "#D6ACFF";
                  "5" = mkColorFromHex "#FF79C6";
                  "D" = mkColorFromHex "#FF92DF";
                  "6" = mkColorFromHex "#8BE9FD";
                  "E" = mkColorFromHex "#A4FFFF";
                  "7" = mkColorFromHex "#F8F8F2";
                  "F" = mkColorFromHex "#FFFFFF";
                };
              };
            }
          );

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

        gnomeCompat = {
          enable = true;

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

      schemes.gtk = {
        enable = true;
        theme.package = pkgs.adw-gtk3;

        accent = "purple";
        inherit (config.windowManager.hyprland.custom.style) scheme;
      };
    };
}
