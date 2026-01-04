{ lib, config, ... }:
{
  options.mixins.programs.telegram =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "telegram config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.telegram;
      inherit (config.programs.telegram) package;
    in
    lib.mkIf cfg.enable {
      programs.telegram.enable = true;

      xdg.autostart.entries = [
        "${package}/share/applications/org.telegram.desktop.desktop"
      ];

      wayland.windowManager.hyprland.settings =
        let
          inherit (config.windowManager.hyprland.custom.binds) mods;
          workspace = "telegram";
        in
        {
          bind = [
            "${mods.app}, T, togglespecialworkspace, ${workspace}"
          ];

          workspace = [
            "special:${workspace}, on-created-empty:${lib.getExe package}"
          ];

          windowrule = [
            "match:class org.telegram.desktop, workspace special:${workspace} silent"
            "match:class org.telegram.desktop, match:title Media viewer, float on, content photo"
          ];
        };
    };
}
