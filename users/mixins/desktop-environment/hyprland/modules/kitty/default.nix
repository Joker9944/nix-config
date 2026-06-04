{ mkDefaultHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-hyprland,
  ...
}:
mkDefaultHyprlandModule { dir = ./.; } (
  let
    cfg = config.mixins.desktopEnvironment.hyprland;
    inherit (lib.generators) mkLuaInline;
  in
  {
    programs.kitty = {
      enable = true;
      package = pkgs-hyprland.kitty;
    };

    mixins.desktopEnvironment.hyprland.terminal = {
      inherit (config.programs.kitty) package;

      mkRunCommand =
        {
          id,
          command,
          ...
        }:
        "kitty --override confirm_os_window_close=0 --app-id ${id} ${command}";

      mkWindowRules =
        { id, ... }:
        [
          {
            name = "kitty-${id}";
            match.class = id;
            min_size = mkLuaInline "{ 720, 480 }";
          }
        ];
    };

    wayland.windowManager.hyprland.settings = {
      bind =
        let
          inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
        in
        [
          {
            _args = [
              "${mods.main} + T"
              (mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
            ];
          }
          {
            _args = [
              "${mods.main} + SPACE"
              (mkLuaInline "hl.dsp.exec_cmd(\"kitten quick-access-terminal\")")
            ];
          }
        ];

      window_rule = cfg.terminal.mkWindowRules {
        id = "kitty";
      };
    };

    # Set as default in other apps
    programs.wofi.settings.term = "kitty";
  }
)
