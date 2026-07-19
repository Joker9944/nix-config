{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-unstable,
  custom,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkHyprlandModule {
  home.packages = [ pkgs-unstable.wl-clipboard ]; # Wayland clipboard utilities

  services.cliphist = {
    enable = true;
    package = pkgs-unstable.cliphist;
  };

  wayland.windowManager.hyprland.settings.bind =
    let
      dmenuCommand = cfg.launcher.mkDmenuCommand { };
    in
    [
      (custom.lib.mkLuaCall [
        "${cfg.binds.mods.utility} + V"
        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"cliphist list | ${dmenuCommand} | cliphist decode | wl-copy\")")
      ])
    ];
}
