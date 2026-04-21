{ lib, config, ... }:
{
  options =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      programs.wallust.templates.kitty = {
        enable = mkEnableOption "kitty wallust config";

        template = mkOption {
          type = types.lines;

          default = ''
            cursor {{ cursor }}

            background {{ background }}
            foreground {{ foreground }}

            color0 {{ color0 }}
            color1 {{ color1 }}
            color2 {{ color2 }}
            color3 {{ color3 }}
            color4 {{ color4 }}
            color5 {{ color5 }}
            color6 {{ color6 }}
            color7 {{ color7 }}
            color8 {{ color8 }}
            color9 {{ color9 }}
            color10 {{ color10 }}
            color11 {{ color11 }}
            color12 {{ color12 }}
            color13 {{ color13 }}
            color14 {{ color14 }}
            color15 {{ color15 }}

            mark1_foreground {{ color6 | saturate(0.2) }}
            mark2_foreground {{ color7 | saturate(0.2) }}
            mark3_foreground {{ color6 | saturate(0.2) }}
          '';

          description = ''
            Template for config snipped which will be sourced in kitty config.
          '';
        };
      };
    };

  config =
    let
      cfg = config.programs.wallust;
    in
    lib.mkIf (cfg.enable && cfg.templates.kitty.enable) {
      xdg.configFile."wallust/templates/kitty.conf".text = cfg.templates.kitty.template;

      programs.wallust.settings.templates.kitty = {
        template = "kitty.conf";
        target = "~/.config/kitty/wallust.conf";
      };

      programs.kitty.extraConfig = ''
        include wallust.conf
      '';
    };
}
