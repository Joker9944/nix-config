{ mkHyprlandModule, ... }:
{ lib, ... }:
let
  regexes = [
    "steam_app_\\S+"
    "gamescope"
  ];
in
mkHyprlandModule {
  wayland.windowManager.hyprland.settings = {
    workspace_rule = [
      {
        workspace = "name:gaming";
        layout = "monocle";
        decorate = false;
      }
    ];

    window_rule = lib.map (regex: {
      name = "gaming-${regex}";
      match.class = regex;
      content = "game";
      opaque = true;
      immediate = true;
      suppress_event = "";
      workspace = "name:gaming";
    }) regexes;

    config = {
      # Enable direct scanout for fullscreen applications marked as game content
      render.direct_scanout = 2;

      # Enable variable refresh rate for fullscreen applications marked as game content
      misc.vrr = 3;
    };
  };
}
