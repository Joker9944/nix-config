{
  lib,
  config,
  pkgs-hyprland,
  utility,
  ...
}:
let
  cfg = config.desktopEnvironment.hyprland;
in
utility.custom.mkHyprlandModule config {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "content game, class:${cfg.steam.appRegex}"
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
