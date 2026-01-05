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
    ++ (with inputs.nix-schemes.homeManagerModules; [
      scheme
      gtk
      librewolf
    ]);

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

      schemes = {
        source.scheme = {
          system = "base16";
          slug = "uwunicorn"; # cSpell:words uwunicorn
        };

        transformers =
          let
            /*
              draculaAnsi =
              _: colorLib:
              let
                mkColorFromHex = hex: colorLib.mkColor (colorLib.fromHex hex);
              in
              {
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
            */
            schemeTransformers = inputs.nix-schemes.lib.transformers;
          in
          [
            (schemeTransformers.interpolateBase24 { })
            schemeTransformers.named
            schemeTransformers.ansi
            #draculaAnsi
            config.schemes.gtk.accentTransformer
          ];

        gtk = {
          enable = true;
          accent = "purple";
          /*
            accentOverride =
            colorLib:
            colorLib.mkColor [
              129
              92
              214
            ];
          */
        };

        librewolf = {
          enable = true;
          profiles = [ "joker9944" ];
        };
      };
    };
}
