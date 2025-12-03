{
  lib,
  config,
  custom,
  ...
}:
let
  regexes = [
    "steam_app_\\\\d+"
    "gamescope"
    "DetectiveGrimoire"
  ];
in
custom.lib.mkHyprlandModule config {
  windowManager.hyprland.custom.system.allowMaximized = regexes;

  wayland.windowManager.hyprland.settings = {
    windowrule = lib.map (regex: "float, decorate 0, content game, class:${regex}") regexes;

    render = {
      # Enable direct scanout for fullscreen applications marked as game content
      direct_scanout = 2;
    };

    misc = {
      # Enable variable refresh rate for fullscreen applications marked as game content
      vrr = 3;
    };
  };
}
