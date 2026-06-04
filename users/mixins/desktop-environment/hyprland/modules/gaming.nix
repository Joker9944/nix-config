{ mkHyprlandModule, ... }:
{ lib, ... }:
let
  regexes = [
    "steam_app_\\\\d+"
    "gamescope"
    "DetectiveGrimoire"
  ];
in
mkHyprlandModule {
  mixins.desktopEnvironment.hyprland.system.allowMaximized = regexes;

  wayland.windowManager.hyprland.settings = {
    window_rule = lib.map (regex: {
      name = "gaming-${regex}";
      match.class = regex;
      content = "game";
      float = true;
      decorate = false;
    }) regexes;

    config = {
      # Enable direct scanout for fullscreen applications marked as game content
      render.direct_scanout = 2;

      # Enable variable refresh rate for fullscreen applications marked as game content
      misc.vrr = 3;
    };
  };
}
