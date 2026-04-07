{
  lib,
  config,
  ...
}:
{
  config =
    let
      cfg = config.mixins.desktopEnvironment.hyprland;
    in
    lib.mkIf cfg.enable {
      programs.regreet = {
        compositor = "hyprland";

        hyprland = {
          inherit (config.programs.hyprland) package;

          settings = {
            windowrule = [ "match:initial_class apps\\.regreet, stay_focused on" ];

            input =
              let
                inherit (config.services.xserver) xkb;
              in
              {
                kb_layout = xkb.layout;
                kb_variant = xkb.variant;
                kb_model = xkb.model;
                kb_options = xkb.options;
              };

            misc.disable_hyprland_logo = true;
          };
        };
      };
    };
}
