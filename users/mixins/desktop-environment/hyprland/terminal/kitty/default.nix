{ mkDefaultHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-hyprland,
  custom,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
  inherit (lib.generators) mkLuaInline;
in
mkDefaultHyprlandModule { dir = ./.; } {
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
          name = "terminal-${id}";
          match.class = id;
          min_size = mkLuaInline "{ 720, 480 }";
        }
      ];
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        inherit (cfg.binds) mods;
        inherit (custom.lib) mkLuaCall;
        inherit (cfg.system) mkLuaRunPart;
      in
      [
        (mkLuaCall [
          "${mods.main} + T"
          (mkLuaRunPart { command = "kitty"; })
        ])
        (mkLuaCall [
          "${mods.main} + SPACE"
          (mkLuaRunPart {
            command = "kitten";
            args = [ "quick-access-terminal" ];
          })
        ])
      ];

    window_rule = cfg.terminal.mkWindowRules { id = "kitty"; };
  };
}
