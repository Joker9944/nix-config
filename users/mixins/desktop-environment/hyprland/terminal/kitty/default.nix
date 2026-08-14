{ mkDefaultHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-unstable,
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
    package = pkgs-unstable.kitty;
  };

  mixins.desktopEnvironment.hyprland.terminal = {
    inherit (config.programs.kitty) package;

    mkRunCommand =
      {
        id,
        command,
        ...
      }:
      cfg.mkAppCommand {
        name = id;
        elems = [
          "kitty"
          "--override"
          "confirm_os_window_close=0"
          "--app-id"
          id
          command
        ];
      };

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
        inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
        inherit (custom.lib.hyprland) mkLuaCall;
        terminalCommand = cfg.mkAppEntryCommand { package = cfg.terminal.package; };
        quickAccessCommand = cfg.mkAppCommand {
          elems = [
            "kitten"
            "quick-access-terminal"
          ];
        };
      in
      [
        (mkLuaCall [
          "${mods.main} + T"
          (mkLuaInline "hl.dsp.exec_cmd(\"${terminalCommand}\")")
        ])
        (mkLuaCall [
          "${mods.main} + SPACE"
          (mkLuaInline "hl.dsp.exec_cmd(\"${quickAccessCommand}\")")
        ])
      ];

    window_rule = cfg.terminal.mkWindowRules { id = "kitty"; };
  };
}
