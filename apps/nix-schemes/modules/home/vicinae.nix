flake:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.schemes.vicinae;
  libSchemes = flake.lib.libSchemes;

  tomlFormat = pkgs.formats.toml { };
in
{
  options.schemes.vicinae =
    let
      inherit (lib) mkEnableOption mkOption;
      customTypes = libSchemes.types;
    in
    {
      enable = mkEnableOption "vicinae theming based on a scheme";

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to customize vicinae.
        '';
      };

      theme = mkOption {
        inherit (tomlFormat) type;
        default = { };
        description = ''
          Additional theme settings added to the generated theme.
        '';
      };
    };

  config =
    let
      inherit (cfg.scheme) palette;

      slug = lib.toLower (builtins.replaceStrings [ " " ] [ "-" ] cfg.scheme.name);

      hex = color: "#${color.hex}";

      # base24 adds brighter accents and deeper backgrounds over base16.
      pick = extended: fallback: hex (if cfg.scheme.system == "base24" then extended else fallback);

      theme = {
        meta = {
          version = 1;
          inherit (cfg.scheme) name variant;
          description = cfg.scheme.author;
          inherits = "vicinae-${cfg.scheme.variant}";
        };

        colors = {
          core = {
            accent = hex cfg.scheme.accent;
            accent_foreground = hex palette.base00;
            background = hex palette.base00;
            foreground = hex palette.base05;
            secondary_background = hex palette.base01;
            border = hex (palette.base02.mix palette.base03 0.4);
          };

          accents = {
            red = hex palette.base08;
            orange = hex palette.base09;
            yellow = hex palette.base0A;
            green = hex palette.base0B;
            cyan = hex palette.base0C;
            blue = hex palette.base0D;
            magenta = hex palette.base0E;
            purple = pick palette.base17 palette.base0E;
          };

          main_window = {
            border = "colors.core.border";
            footer.background = hex palette.base01;
          };

          settings_window.border = "colors.core.border";

          shortcut.border = "colors.core.border";

          text = {
            default = "colors.core.foreground";
            muted = hex palette.base04;
            placeholder = hex palette.base03;
            danger = pick palette.base12 palette.base08;
            success = pick palette.base14 palette.base0B;

            selection = {
              background = "colors.core.accent";
              foreground = "colors.core.accent_foreground";
            };

            links = {
              default = pick palette.base16 palette.base0D;
              visited = pick palette.base17 palette.base0E;
            };
          };

          input = {
            border = "colors.core.border";
            border_focus = "colors.core.accent";
            border_error = pick palette.base12 palette.base08; # references only resolve into core and accents
          };

          button.primary = {
            background = hex palette.base02;
            foreground = "colors.core.foreground";
            hover.background = "#bb${palette.base02.hex}"; # AARRGGBB
            focus.outline = "colors.core.accent";
          };

          list.item = {
            hover = {
              foreground = "colors.core.foreground";
              secondary_foreground = hex palette.base04;
            };

            selection = {
              background = hex palette.base02;
              foreground = "colors.core.foreground";
              secondary_background = "colors.core.accent";
              secondary_foreground = hex palette.base04;
            };
          };

          grid.item = {
            background = hex palette.base01;
            hover.outline = "colors.core.accent";
            selection.outline = "colors.core.accent";
          };

          scrollbars.background = "colors.core.border";

          loading = {
            bar = "colors.core.accent";
            spinner = "colors.core.foreground";
          };
        };
      };
    in
    lib.mkIf cfg.enable {
      programs.vicinae = {
        settings = {
          theme.${cfg.scheme.variant}.name = lib.mkDefault slug;
          providers.theme.entrypoints.set.enabled = lib.mkDefault false;
        };

        themes.${slug} = lib.recursiveUpdate theme cfg.theme;
      };
    };
}
