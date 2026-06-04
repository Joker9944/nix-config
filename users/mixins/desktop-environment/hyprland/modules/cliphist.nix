{ mkHyprlandModule, ... }:
{
  lib,
  config,
  pkgs-hyprland,
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
      inherit (cfg.binds) mods;
      inherit (lib.generators) mkLuaInline;
      bin = {
        wl-copy = lib.getExe' pkgs-hyprland.wl-clipboard "wl-copy";
        cliphist = lib.getExe pkgs-hyprland.cliphist;
      };
      dmenuCommand = cfg.launcher.mkDmenuCommand { };
    in
    [
      {
        _args = [
          "${mods.utility} + V"
          (mkLuaInline "hl.dsp.exec_cmd(\"${bin.cliphist} list | ${dmenuCommand} | ${bin.cliphist} decode | ${bin.wl-copy}\")")
        ];
      }
    ];
}
