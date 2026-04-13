{ mkHyprlandModule, ... }:
{ lib, config, ... }:
let
  inherit (cfg.binds) mods;
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
        command = cfg.terminal.mkRunCommand {
          id = "numbat";
          command = bin.numbat;
        };
      in
      [ "${mods.app}, C, exec, ${command}" ];

    windowrule = cfg.terminal.mkWindowRules {
      id = "numbat";
    };
  };
}
