{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.jetbrains =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "jetbrains config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.jetbrains;
    in
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [ nodejs ];

      programs = {
        jetbrains = {
          idea = {
            enable = true;

            vmoptions = [
              "-Xmx4096m"
              { "-Dawt.toolkit.name" = "WLToolkit"; }
            ];
          };

          webstorm = {
            enable = true;

            vmoptions = [
              "-Xmx4096m"
              { "-Dawt.toolkit.name" = "WLToolkit"; }
            ];
          };

          pycharm.enable = true;

          goland.enable = true;
        };

        openjdk.versions = [
          8
          11
          17
          21
          25
        ];
      };

      wayland.windowManager.hyprland.settings.windowrule = [
        "match:class ^jetbrains-.+$, match:initial_title ^$, no_initial_focus on"
      ];
    };
}
