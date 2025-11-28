/**
  * terminal
*/
{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  inherit (cfg.binds) mods;
  cfg = config.windowManager.hyprland.custom;
  bin = {
    kitty = lib.getExe config.programs.kitty.package;
    kitten = lib.getExe' config.programs.kitty.package "kitten";
  };
in
utility.custom.mkHyprlandModule config {
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  config = {
    programs.kitty = {
      enable = true;
      package = pkgs-hyprland.kitty;
    };

    windowManager.hyprland.custom.terminal = {
      inherit (config.programs.kitty) package;

      mkRunCommand =
        {
          id,
          command,
          ...
        }:
        "${bin.kitty} --override confirm_os_window_close=0 --app-id ${id} ${command}";

      mkWindowRules = { id, ... }: [ "minsize 720 480, class:${id}" ];
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        "${mods.main}, T, exec, ${bin.kitty}"
        "${mods.main}, SPACE, exec, SKIP_FASTFETCH=true ${bin.kitten} quick-access-terminal"
      ];

      windowrule = cfg.terminal.mkWindowRules {
        id = "kitty";
      };
    };

    # Set as default in other apps
    programs.wofi.settings.term = "kitty";
  };
}
