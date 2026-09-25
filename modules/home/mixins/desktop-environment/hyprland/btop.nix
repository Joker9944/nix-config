{ mkHyprlandModule, flake, ... }:
{
  lib,
  config,
  osConfig,
  pkgs-unstable,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
  id = "btop";
in
mkHyprlandModule {
  programs.btop = {
    enable = true;
    package =
      if lib.lists.elem "nvidia" osConfig.services.xserver.videoDrivers then
        pkgs-unstable.btop-cuda
      else
        pkgs-unstable.btop;
  };

  wayland.windowManager.hyprland.settings = {
    bind =
      let
        inherit (cfg.binds) mods;
        inherit (flake.lib.hyprland) mkLuaCall;
        inherit (lib.generators) mkLuaInline;
      in
      [
        (mkLuaCall [
          "${mods.app} + B"
          (mkLuaInline "hl.dsp.workspace.toggle_special(\"${id}\")")
          { description = "toggle btop special workspace"; }
        ])
      ];

    workspace_rule = [
      {
        workspace = "special:${id}";
        layout = "scrolling";
        on_created_empty = cfg.terminal.mkRunCommand {
          inherit id;
          command = "btop";
        };
      }
    ];

    window_rule = cfg.terminal.mkWindowRules { inherit id; } ++ [
      {
        name = "btop-special";
        match.class = id;
        workspace = "special:${id} silent";
      }
    ];
  };
}
