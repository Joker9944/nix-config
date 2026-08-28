{ flake, ... }@moduleArgs:
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;

    args = moduleArgs // {
      mkThemeModule = flake.lib.modules.mkMixinModule {
        inherit config;
        prefix = [ "theme" ];
      };
    };
  }
  {
    options.custom.theme =
      let
        inherit (lib) mkOption types;

        # The module-arg `lib` carries `hm` only inside the home-manager tree; the flake
        # input exposes it to both. GTK's icon/cursor types are not exported the same way.
        inherit (inputs.home-manager.lib.hm.types) fontType;
      in
      {
        accent = mkOption {
          type = types.str;
          default = "base0D";
          example = "#B478AE";
          description = ''
            Accent color of the active theme, either a palette slot name or a hex string.
          '';
        };

        gtk = {
          accent = mkOption {
            type = types.enum [
              "blue"
              "teal"
              "green"
              "yellow"
              "orange"
              "red"
              "pink"
              "purple"
              "slate"
            ];
            default = "blue";
            description = ''
              The GTK accent color based on the GTK 4 accent system.
            '';
          };

          uniformAccents = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Collapse all nine GTK accents onto `accent`. A theme naming one color wants
              this; a theme drawing its accents from the palette must not.
            '';
          };
        };

        fonts = {
          interface = mkOption {
            type = fontType;
            description = ''
              Interface text font of the active theme.
            '';
          };

          terminal = mkOption {
            type = fontType;
            description = ''
              Terminal text font of the active theme.
            '';
          };

          document = mkOption {
            type = fontType;
            description = ''
              Document text font of the active theme.
            '';
          };

          monospace = mkOption {
            type = fontType;
            description = ''
              Monospace text font of the active theme.
            '';
          };

          emoji = mkOption {
            type = fontType;
            description = ''
              Emoji font of the the active theme.
            '';
          };
        };
      };

    config =
      let
        cfg = config.custom.theme;
      in
      {
        custom.theme.fonts = {
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

          document = {
            name = "Lato";
            package = pkgs.lato;
            size = 12;
          };

          monospace = {
            name = "JetBrains Mono";
            package = pkgs.jetbrains-mono;
            size = 10;
          };

          emoji = {
            name = "Noto Color Emoji";
            package = pkgs.noto-fonts-color-emoji;
            size = 10;
          };
        };

        schemes.accent = cfg.accent;
      };
  }
