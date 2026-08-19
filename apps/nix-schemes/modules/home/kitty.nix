# https://sw.kovidgoyal.net/kitty/conf/
flake:
{
  lib,
  config,
  ...
}:
let
  cfg = config.schemes.kitty;
  libSchemes = flake.lib.libSchemes;
in
{
  options.schemes.kitty =
    let
      inherit (lib) mkEnableOption mkOption;
      customTypes = libSchemes.types;
    in
    {
      enable = mkEnableOption "kitty theming based on a scheme";

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to customize kitty.
        '';
      };
    };

  config =
    let
      inherit (cfg.scheme) palette;

      accent = libSchemes.requireKey cfg.scheme "accent";
      ansi = libSchemes.requireKey cfg.scheme "ansi";

      hex = color: "#${color.hex}";

      # base24 adds deeper backgrounds over base16; base10 falls back to base00 per spec.
      pick = extended: fallback: hex (if cfg.scheme.system == "base24" then extended else fallback);

      settings = {
        foreground = hex palette.base05;
        background = hex palette.base00;
        selection_foreground = hex palette.base05;
        selection_background = hex palette.base02;

        cursor = hex accent;
        cursor_text_color = hex palette.base00;

        url_color = hex palette.base0D;

        active_border_color = hex accent;
        inactive_border_color = hex palette.base02;
        bell_border_color = hex palette.base09;

        active_tab_foreground = hex palette.base00;
        active_tab_background = hex accent;
        inactive_tab_foreground = hex palette.base04;
        inactive_tab_background = hex palette.base01;
        tab_bar_background = pick palette.base10 palette.base00;

        mark1_foreground = hex palette.base00;
        mark1_background = hex palette.base0D;
        mark2_foreground = hex palette.base00;
        mark2_background = hex palette.base0E;
        mark3_foreground = hex palette.base00;
        mark3_background = hex palette.base0C;
      }
      // (lib.concatMapAttrs (name: color: {
        "color${toString (lib.fromHexString name)}" = hex color;
      }) ansi);
    in
    lib.mkIf cfg.enable {
      programs.kitty.settings = lib.mapAttrs (_: lib.mkDefault) settings;
    };
}
