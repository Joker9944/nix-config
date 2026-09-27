{ mkDefaultHyprlandModule, flake, ... }:
{
  lib,
  config,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkDefaultHyprlandModule { dir = ./.; } {
  options.mixins.desktopEnvironment.hyprland.launcher =
    let
      inherit (lib) mkOption types;
    in
    {
      toggleCommand = mkOption {
        type = types.str;
        example = "vicinae toggle";
        description = ''
          Command to toggle the launcher.
        '';
      };
    };

  config = {
    assertions = [
      {
        assertion =
          lib.count (l: l.enable or false) (lib.filter lib.isAttrs (lib.attrValues cfg.launcher)) <= 1;
        message = "hyprland: enable at most one launcher, got ${
          toString (lib.attrNames (lib.filterAttrs (_: l: l.enable) cfg.launcher))
        }";
      }
    ];

    mixins.desktopEnvironment.hyprland.launcher.vicinae.enable = true;

    wayland.windowManager.hyprland.settings =
      let
        inherit (cfg.binds) mods;
        inherit (flake.lib.hyprland) mkLuaCall;
        inherit (lib.generators) mkLuaInline;
      in
      {
        bind = [
          (mkLuaCall [
            "${mods.main} + R"
            (mkLuaInline "hl.dsp.exec_cmd(\"${cfg.launcher.toggleCommand}\")")
            { description = "toggle the launcher"; }
          ])
          (mkLuaCall [
            "${mods.main} + ${mods.main}_L"
            (mkLuaInline "hl.dsp.exec_cmd(\"${cfg.launcher.toggleCommand}\")")
            {
              description = "toggle the launcher (tap super)";
              release = true;
            }
          ])
        ];
      };
  };
}
