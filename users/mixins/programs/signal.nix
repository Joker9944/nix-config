{ mkMixinModule, ... }:
{
  lib,
  config,
  custom,
  ...
}:
mkMixinModule "signal" {
  config =
    let
      workspace = "signal";
    in
    {
      programs.signal.enable = true;

      wayland.windowManager.hyprland.settings = {
        bind =
          let
            inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
            inherit (custom.lib) mkLuaCall;
            inherit (lib.generators) mkLuaInline;
          in
          [
            (mkLuaCall [
              "${mods.app} + G"
              (mkLuaInline "hl.dsp.workspace.toggle_special(\"${workspace}\")")
            ])
          ];

        workspace_rule = [
          {
            workspace = "special:${workspace}";
            on_created_empty = "signal-desktop";
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
