{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.mixins.programs.discord =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "discord config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.discord;
    in
    lib.mkIf cfg.enable {
      programs.discord = {
        enable = true;
        package = pkgs.vesktop;
      };

      wayland.windowManager.hyprland.settings =
        let
          inherit (config.programs.discord) package;
          workspace = "discord";
        in
        {
          bind =
            let
              inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
              inherit (lib.generators) mkLuaInline;
            in
            [
              {
                _args = [
                  "${mods.app} + D"
                  (mkLuaInline "hl.dsp.workspace.toggle_special(\"${workspace}\")")
                ];
              }
            ];

          workspace_rule = [
            {
              workspace = "special:${workspace}";
              on_created_empty = "${lib.getExe package}";
            }
          ];

          window_rule = [
            {
              name = "vesktop";
              match.class = "vesktop";
              workspace = "special:${workspace} silent";
            }
          ];
        };
    };
}
