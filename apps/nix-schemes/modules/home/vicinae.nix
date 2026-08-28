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

      settings = mkOption {
        inherit (tomlFormat) type;
        default = { };
        description = ''
          Theme settings merged over the generated theme. The output lands in
          `programs.vicinae.themes`, so this is the override channel — there are no
          per-color options.
        '';
      };
    };

  config =
    let
      inherit (cfg.scheme) palette accent;

      hex = color: "#${color.hex}";

      theme = {
        meta = {
          version = 1;
          inherit (cfg.scheme.meta) name variant;
          description = cfg.scheme.meta.author;
          inherits = "vicinae-${cfg.scheme.meta.variant}";
        };

        colors = {
          core = {
            accent = hex accent;
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
            purple = hex palette.base17;
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
            danger = hex palette.base12;
            success = hex palette.base14;

            selection = {
              background = "colors.core.accent";
              foreground = "colors.core.accent_foreground";
            };

            links = {
              default = hex palette.base16;
              visited = hex palette.base17;
            };
          };

          input = {
            border = "colors.core.border";
            border_focus = "colors.core.accent";
            border_error = hex palette.base12; # references only resolve into core and accents
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
          theme.${cfg.scheme.meta.variant}.name = lib.mkDefault cfg.scheme.meta.slug;
          providers.theme.entrypoints.set.enabled = lib.mkDefault false;
        };

        themes.${cfg.scheme.meta.slug} = lib.recursiveUpdate theme cfg.settings;
      };
    };
}
