{
  lib,
  config,
  options,
  ...
}:
{
  options =
    let
      inherit (lib) mkEnableOption mkOption literalExpression;
    in
    {
      programs.wallust.templates.hyprlock = {
        enable = mkEnableOption "hyprlock wallust config";

        template = mkOption {
          inherit (options.programs.hyprlock.settings) type;

          example = literalExpression ''
            {
              general = {
                  # Here we use `saturate` filter to have more vibrant colors,
                  # not matter the scheme, since the border should seek the attention
                  col.active_border = "rgb({{color1 | saturate(0.6) | strip}}) rgb({{color2 | saturate(0.6) | strip}}) rgb({{color3 | saturate(0.6) | strip}}) rgb({{color4 | saturate(0.6) | strip}}) rgb({{color5 | saturate(0.6) | strip}}) rgb({{color6 | saturate(0.6) | strip}})";
                  # color0 is almost the same as the background color,
                  # by putting ee as the alpha, it makes it 100% transparent
                  col.inactive_border = "rgba({{color0 | strip}}ee)";
              };
            }
          '';

          description = ''
            Template for config snipped which will be sourced in hyprlock config.

            Hyprland configuration written in Nix. Entries with the same key
            should be written as lists. Variables' and colors' names should be
            quoted. See <https://wiki.hypr.land> for more examples.
          '';
        };
      };
    };

  config =
    let
      cfg = config.programs.wallust;
    in
    lib.mkIf (cfg.enable && cfg.templates.hyprlock.enable) {
      xdg.configFile."wallust/templates/hyprlock.conf".text = lib.hm.generators.toHyprconf {
        attrs = cfg.templates.hyprlock.template;
      };

      programs = {
        wallust.settings.templates.hyprlock = {
          template = "hyprlock.conf";
          target = "~/.config/hypr/wallust-hyprlock.conf";
        };

        hyprlock.settings.source = "~/.config/hypr/wallust-hyprlock.conf";
      };
    };
}
