{
  inputs,
  lib,
  config,
  pkgs-unstable,
  custom,
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

        extraCss = ''
          window, overlay {
            background-color: transparent;
          }
        '';

        hyprland = {
          inherit (config.programs.hyprland) package;

          execOnce = [
            "${lib.getExe pkgs-unstable.hyprpaper} --config ${
              pkgs-unstable.writeTextFile {
                name = "greet-hyprpaper.conf";
                text = inputs.home-manager.lib.hm.generators.toHyprconf {
                  attrs = {
                    splash = false;

                    wallpaper = [
                      {
                        monitor = "";
                        path = "${custom.assets.black-sand-dunes}";
                      }
                    ];
                  };
                };
              }
            }"
          ];

          settings = {
            window_rule = [
              {
                match.initial_class = "apps\\.regreet";
                no_blur = true;
                stay_focused = true;
              }
            ];

            config = {
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
    };
}
