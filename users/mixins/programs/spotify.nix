{ lib, config, ... }:
{
  options.mixins.programs.spotify =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "spotify config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.spotify;
    in
    lib.mkIf cfg.enable {
      programs.spotify.enable = true;

      wayland.windowManager.hyprland.settings =
        let

          inherit (config.programs.spotify) package;
          workspace = "spotify";
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
                  "${mods.app} + S"
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
              name = "spotify";
              match.class = "Spotify";
              workspace = "special:${workspace} silent";
            }
          ];
        };
    };
}
