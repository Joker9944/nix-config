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
      programs.wallust.templates.hyprland = {
        enable = mkEnableOption "hyprland wallust config";

        template = mkOption {
          inherit (options.wayland.windowManager.hyprland.settings) type;

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
            Template for config snipped which will be sourced in hyprland config.

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
    lib.mkIf (cfg.enable && cfg.templates.hyprland.enable) {
      xdg.configFile."wallust/templates/hyprland.conf".text = lib.hm.generators.toHyprconf {
        attrs = cfg.templates.hyprland.template;
      };

      programs.wallust.settings.templates.hyprland = {
        template = "hyprland.conf";
        target = "~/.config/hypr/wallust-hyprland.conf";
      };

      wayland.windowManager.hyprland.settings.source = "~/.config/hypr/wallust-hyprland.conf";
    };
}
