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
          inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
          inherit (config.programs.spotify) package;
          workspace = "spotify";
        in
        {
          bind = [
            "${mods.app}, S, togglespecialworkspace, ${workspace}"
          ];

          workspace = [
            "special:${workspace}, on-created-empty:${lib.getExe package}"
          ];

          windowrule = [
            "match:class Spotify, workspace special:${workspace}"
          ];
        };
    };
}
