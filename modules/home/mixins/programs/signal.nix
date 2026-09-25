{ mkMixinModule, flake, ... }:
{
  lib,
  config,
  ...
}:
mkMixinModule "signal" {
  config =
    let
      inherit (config.programs.signal) package;
      cfg = config.mixins.desktopEnvironment.hyprland;
      workspace = "signal";
    in
    {
      programs.signal.enable = true;

      wayland.windowManager.hyprland.settings = {
        bind =
          let
            inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
            inherit (flake.lib.hyprland) mkLuaCall;
            inherit (lib.generators) mkLuaInline;
          in
          [
            (mkLuaCall [
              "${mods.app} + G"
              (mkLuaInline "hl.dsp.workspace.toggle_special(\"${workspace}\")")
              { description = "toggle signal special workspace"; }
            ])
          ];

        workspace_rule = [
          {
            workspace = "special:${workspace}";
            layout = "scrolling";
            on_created_empty = cfg.mkAppEntryCommand {
              inherit package;
              name = "signal.desktop";
            };
          }
        ];

        window_rule = [
          {
            name = "signal";
            match.class = "signal";
            workspace = "special:${workspace}";
          }
        ];
      };
    };
}
