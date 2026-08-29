{ mkHyprlandModule, flake, ... }:
{
  lib,
  config,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
  id = "numbat";
in
mkHyprlandModule {
  programs.numbat = {
    enable = true;

    settings = {
      prompt = "> ";
    };
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        inherit (cfg.binds) mods;
        inherit (flake.lib.hyprland) mkLuaCall;
        inherit (lib.generators) mkLuaInline;
        command = cfg.terminal.mkRunCommand {
          inherit id;
          command = "numbat";
        };
      in
      [
        (mkLuaCall [
          "${mods.app} + C"
          (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
        ])
      ];

    window_rule = cfg.terminal.mkWindowRules { inherit id; };
  };
}
