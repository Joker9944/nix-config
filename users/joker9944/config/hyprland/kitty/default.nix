/**
  * terminal
*/
{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
  bin.kitty = "${config.programs.kitty.package}/bin/kitty";
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

      settings = {
        # look
        cursor_shape = "beam";
      };
    };

    desktopEnvironment.hyprland.terminal = {
      mkTuiCommand =
        {
          id,
          command,
          ...
        }:
        "${bin.kitty} --override confirm_os_window_close=0 --app-id ${id} ${command}";

      mkWindowRules = { id, ... }: [ "minsize 720 480, class:${id}" ];
    };

    wayland.windowManager.hyprland.settings = {
      bind =
        let
          inherit (cfg.bind) mods;
        in
        [ "${mods.main}, T, exec, ${bin.kitty}" ];

      windowrule = cfg.terminal.mkWindowRules {
        id = "kitty";
      };
    };

    # Set as default in other apps
    programs.wofi.settings.term = "kitty";
  };
}
