{ mkHyprlandModule, ... }:
{ config, custom, ... }:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkHyprlandModule {
  wayland.windowManager.hyprland.settings.bind =
    let
      inherit (cfg.binds) mods;
    in
    [
      (custom.lib.mkLuaCall [
        "${mods.main} + B"
        (cfg.system.mkLuaRunPart { command = "librewolf"; })
        { description = "open the default browser"; }
      ])
    ];
}
