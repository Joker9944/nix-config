{
  lib,
  config,
  custom,
  ...
}:
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
      workspace = "spotify";
    in
    lib.mkIf cfg.enable {
      programs.spotify.enable = true;

      wayland.windowManager.hyprland.settings = {
        bind =
          let
            inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
            inherit (custom.lib) mkLuaCall;
            inherit (lib.generators) mkLuaInline;
          in
          [
            (mkLuaCall [
              "${mods.app} + S"
              (mkLuaInline "hl.dsp.workspace.toggle_special(\"${workspace}\")")
            ])
          ];

        workspace_rule = [
          {
            workspace = "special:${workspace}";
            on_created_empty = "spotify";
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
