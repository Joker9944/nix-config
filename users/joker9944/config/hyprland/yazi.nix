/**
  * file explorer
*/
{
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
  bin.yazi = "${config.programs.yazi.package}/bin/yazi";
in
utility.custom.mkHyprlandModule config {
  programs.yazi = {
    enable = true;
    package = pkgs-hyprland.yazi;
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        inherit (cfg.bind) mods;
        command = cfg.terminal.mkTuiCommand {
          id = "yazi";
          command = bin.yazi;
        };
      in
      [ "${mods.main}, E, exec, ${command}" ];

    windowrule = cfg.terminal.mkWindowRules {
      id = "yazi";
    };
  };
}
