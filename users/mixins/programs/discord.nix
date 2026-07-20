{ mkMixinModule, ... }:
{
  lib,
  config,
  custom,
  ...
}:
mkMixinModule "discord" {
  config =
    let
      workspace = "discord";
    in
    {
      programs.vesktop.enable = true;

      wayland.windowManager.hyprland.settings = {
        bind =
          let
            inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
            inherit (custom.lib) mkLuaCall;
            inherit (lib.generators) mkLuaInline;
          in
          [
            (mkLuaCall [
              "${mods.app} + D"
              (mkLuaInline "hl.dsp.workspace.toggle_special(\"${workspace}\")")
            ])
          ];

        workspace_rule = [
          {
            workspace = "special:${workspace}";
            on_created_empty = "vesktop";
          }
        ];

        window_rule = [
          {
            name = "discord";
            match.class = "vesktop";
            workspace = "special:${workspace} silent";
          }
        ];
      };
    };
}
