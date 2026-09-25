{ mkDefaultHyprlandModule, flake, ... }:
{
  lib,
  config,
  pkgs-unstable,
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
        inherit (flake.lib.hyprland) mkLuaCall;
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
          { description = "open a terminal"; }
        ])
        (mkLuaCall [
          "${mods.variant} + T"
          # focused kitty: same-cwd OS window via its remote-control socket; otherwise plain terminal
          (mkLuaInline "hl.dsp.exec_cmd(\"pid=$(hyprctl activewindow | sed -n 's/^[[:space:]]*pid: //p'); kitten @ --to unix:@kitty-$pid launch --type=os-window --cwd=current || ${terminalCommand}\")")
          { description = "open a terminal at the focused terminal's cwd"; }
        ])
        (mkLuaCall [
          "${mods.main} + SPACE"
          (mkLuaInline "hl.dsp.exec_cmd(\"${quickAccessCommand}\")")
          { description = "toggle the quick-access terminal"; }
        ])
      ];

    window_rule = cfg.terminal.mkWindowRules { id = "kitty"; };
  };
}
