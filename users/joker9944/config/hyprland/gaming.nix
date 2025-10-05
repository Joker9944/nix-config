{
  lib,
  config,
  utility,
  ...
}:
utility.custom.mkHyprlandModule config {
  windowManager.hyprland.custom.system.allowMaximized = [
    "steam_app_.+"
    "gamescope"
  ];

  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "content game, class:steam_app_.+"
      "content game, class:gamescope"
      "float, class:gamescope"
    ]
    ++ (lib.map (rule: "${rule}, content:game") [
      "noanim 1"
      "noblur 1"
      "noborder 1"
      "nodim 1"
      "norounding 1"
      "noshadow 1"
      "immediate 1"
      "opacity 1.0 override 1.0 override 1.0 override"
    ]);

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
