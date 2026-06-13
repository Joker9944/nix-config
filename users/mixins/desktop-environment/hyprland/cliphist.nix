{ mkHyprlandModule, ... }:
{
  config,
  pkgs-hyprland,
  custom,
  ...
}:
let
  cfg = config.mixins.desktopEnvironment.hyprland;
in
mkHyprlandModule {
  home.packages = [ pkgs-hyprland.wl-clipboard ]; # Wayland clipboard utilities

  services.cliphist = {
    enable = true;
    package = pkgs-hyprland.cliphist;
  };

  wayland.windowManager.hyprland.settings.bind =
    let
      dmenuCommand = cfg.launcher.mkDmenuCommand { };
      callPart = cfg.system.mkLuaRunPart {
        command = "cliphist list | ${dmenuCommand} | cliphist decode | wl-copy";
      };
    in
    [
      (custom.lib.mkLuaCall [
        "${cfg.binds.mods.utility} + V"
        callPart
      ])
    ];
}
