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
          inherit (config.windowManager.hyprland.custom.binds) mods;
          inherit (config.programs.discord) package;
          workspace = "discord";
        in
        {
          bind = [
            "${mods.app}, D, togglespecialworkspace, ${workspace}"
          ];

          workspace = [
            "special:${workspace}, on-created-empty:${lib.getExe package}"
          ];

          windowrule = [
            "workspace special:${workspace}, class:vesktop"
          ];
        };
    };
}
