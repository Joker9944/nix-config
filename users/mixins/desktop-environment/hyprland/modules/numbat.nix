{ mkHyprlandModule, ... }:
{ lib, config, ... }:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
  bin.numbat = lib.getExe config.programs.numbat.package;
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
        inherit (lib.generators) mkLuaInline;
        command = cfg.terminal.mkRunCommand {
          id = "numbat";
          command = bin.numbat;
        };
      in
      [
        {
          _args = [
            "${mods.app} + C"
            (mkLuaInline "hl.dsp.exec_cmd(\"${command}\")")
          ];
        }
      ];

    window_rule = cfg.terminal.mkWindowRules {
      id = "numbat";
    };
  };
}
